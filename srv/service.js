const cds = require('@sap/cds');

/**
 * SalesService business logic:
 *  - Validation : Quantity > 0, UnitPrice > 0, unique SalesOrderNo
 *  - Calculation: Item.NetAmount = Quantity * UnitPrice
 *                 Order.TotalAmount = SUM(Item.NetAmount)
 *
 * The handlers work for both:
 *  - classic deep-insert (POST SalesOrders with Items in the payload), and
 *  - draft activation (Fiori Elements), where CAP passes the full composition
 *    tree (header + Items) into the CREATE/UPDATE handler of the root entity.
 */
module.exports = cds.service.impl(async function () {

  const { SalesOrders, SalesOrderItems } = this.entities;

  const round2 = (n) => Math.round((Number(n) + Number.EPSILON) * 100) / 100;

  // ---------------------------------------------------------------------------
  // Item-level: validate + compute NetAmount (direct item CRUD, e.g. PATCH item)
  // ---------------------------------------------------------------------------
  this.before(['CREATE', 'UPDATE'], 'SalesOrderItems', (req) => {
    const { Quantity, UnitPrice } = req.data;

    if (Quantity != null && Number(Quantity) <= 0)
      req.error({ code: 'QTY_INVALID', message: 'Quantity must be greater than 0', target: 'Quantity', status: 400 });

    if (UnitPrice != null && Number(UnitPrice) <= 0)
      req.error({ code: 'PRICE_INVALID', message: 'Unit Price must be greater than 0', target: 'UnitPrice', status: 400 });

    if (Quantity != null && UnitPrice != null)
      req.data.NetAmount = round2(Quantity * UnitPrice);
  });

  // ---------------------------------------------------------------------------
  // Header-level: validate items in the tree, compute totals, enforce unique No.
  // ---------------------------------------------------------------------------
  this.before(['CREATE', 'UPDATE'], 'SalesOrders', async (req) => {
    const order = req.data;

    // 1) Unique SalesOrderNo (check against active table, excluding self on update)
    if (order.SalesOrderNo) {
      const where = { SalesOrderNo: order.SalesOrderNo };
      if (order.ID) where.ID = { '!=': order.ID };
      const dup = await SELECT.one.from(SalesOrders).where(where);
      if (dup)
        req.error({ code: 'SO_NO_DUPLICATE', message: `Sales Order No '${order.SalesOrderNo}' already exists`, target: 'SalesOrderNo', status: 400 });
    }

    // 2) Validate items + (re)compute NetAmount and the header TotalAmount
    if (Array.isArray(order.Items)) {
      let total = 0;
      for (const item of order.Items) {
        if (item.Quantity != null && Number(item.Quantity) <= 0)
          req.error({ message: `Item ${item.ItemNo ?? ''}: Quantity must be greater than 0`, status: 400 });

        if (item.UnitPrice != null && Number(item.UnitPrice) <= 0)
          req.error({ message: `Item ${item.ItemNo ?? ''}: Unit Price must be greater than 0`, status: 400 });

        if (item.Quantity != null && item.UnitPrice != null)
          item.NetAmount = round2(item.Quantity * item.UnitPrice);

        total += Number(item.NetAmount || 0);
      }
      order.TotalAmount = round2(total);
    }
  });

  // ---------------------------------------------------------------------------
  // Recompute the header total whenever a single item is created/updated/deleted
  // outside of a full deep-insert (keeps TotalAmount consistent in all flows).
  // ---------------------------------------------------------------------------
  this.after(['CREATE', 'UPDATE', 'DELETE'], 'SalesOrderItems', async (_, req) => {
    const orderId = req.data?.SalesOrder_ID || req.data?.SalesOrder?.ID;
    if (!orderId) return;

    const items = await SELECT.from(SalesOrderItems).where({ SalesOrder_ID: orderId });
    const total = round2(items.reduce((sum, i) => sum + Number(i.NetAmount || 0), 0));
    await UPDATE(SalesOrders, orderId).with({ TotalAmount: total });
  });
});
