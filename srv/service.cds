using { sales } from '../db/schema';
using { sap.common } from '@sap/cds/common';

/**
 * OData V4 service exposing Sales Orders + Items with full CRUD and draft handling.
 * Reachable at:  /odata/v4/sales/SalesOrders
 */
service SalesService @(path: '/odata/v4/sales') {

  // Draft handling is enabled on the root. Because Items is a Composition,
  // draft state cascades to the items automatically (inline create/edit/delete).
  @odata.draft.enabled
  entity SalesOrders      as projection on sales.SalesOrders;

  // Exposed for direct access / deep-insert addressing; managed through the draft root in Fiori.
  entity SalesOrderItems  as projection on sales.SalesOrderItems;

  // Value-help collections (read-only)
  @readonly entity OrderStatus as projection on sales.OrderStatus;
  @readonly entity Currencies  as projection on common.Currencies;
}
