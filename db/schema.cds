namespace sales;

using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

/**
 * Sales Order header.
 * - `cuid`    adds the UUID key element `ID`.
 * - `managed` adds createdAt (Timestamp), createdBy (String), modifiedAt, modifiedBy.
 *   These satisfy the "CreatedAt : Timestamp" and "CreatedBy : String(100)" requirements.
 */
entity SalesOrders : cuid, managed {
  SalesOrderNo : String(20);
  CustomerID   : String(20);
  CustomerName : String(100);
  OrderDate    : Date;
  Status       : String(20)  default 'New';
  TotalAmount  : Decimal(15,2) default 0;
  Currency     : String(3)   default 'USD';

  // Composition => items are OWNED by the order.
  // Deleting a SalesOrder cascades and deletes all its items.
  Items        : Composition of many SalesOrderItems
                   on Items.SalesOrder = $self;
}

/**
 * Sales Order line item (child of SalesOrders via Composition).
 */
entity SalesOrderItems : cuid {
  // Managed association back to the owning order (filled automatically by CAP).
  SalesOrder   : Association to SalesOrders;
  ItemNo       : Integer;
  ProductID    : String(40);
  ProductName  : String(100);
  Quantity     : Decimal(13,3);
  UnitPrice    : Decimal(15,2);
  NetAmount    : Decimal(15,2);   // calculated = Quantity * UnitPrice
  Currency     : String(3) default 'USD';
}

/**
 * Code list used as a fixed-value help for SalesOrders.Status.
 * Inherits `name` and `descr` (localized) from sap.common.CodeList.
 */
entity OrderStatus : CodeList {
  key code : String(20);
}
