using { SalesService } from '../srv/service';

/////////////////////////////////////////////////////////////////////////////
//  SALES ORDERS  –  List Report + Object Page
/////////////////////////////////////////////////////////////////////////////

annotate SalesService.SalesOrders with @(

  // ---- Header of the Object Page -------------------------------------------
  UI.HeaderInfo : {
    $Type          : 'UI.HeaderInfoType',
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { $Type : 'UI.DataField', Value : SalesOrderNo },
    Description    : { $Type : 'UI.DataField', Value : CustomerName }
  },

  // ---- Filter bar of the List Report ---------------------------------------
  UI.SelectionFields : [
    SalesOrderNo,
    CustomerName,
    Status,
    OrderDate
  ],

  // ---- Table of the List Report --------------------------------------------
  UI.LineItem : [
    { $Type : 'UI.DataField', Value : SalesOrderNo },
    { $Type : 'UI.DataField', Value : CustomerName },
    { $Type : 'UI.DataField', Value : Status },
    { $Type : 'UI.DataField', Value : OrderDate },
    { $Type : 'UI.DataField', Value : TotalAmount },
    { $Type : 'UI.DataField', Value : Currency }
  ],

  // ---- Object Page title area action target --------------------------------
  UI.Identification : [
    { $Type : 'UI.DataField', Value : SalesOrderNo }
  ],

  // ---- General Information field group (Object Page) ------------------------
  UI.FieldGroup #General : {
    $Type : 'UI.FieldGroupType',
    Data  : [
      { $Type : 'UI.DataField', Value : SalesOrderNo },
      { $Type : 'UI.DataField', Value : CustomerID },
      { $Type : 'UI.DataField', Value : CustomerName },
      { $Type : 'UI.DataField', Value : OrderDate },
      { $Type : 'UI.DataField', Value : Status },
      { $Type : 'UI.DataField', Value : TotalAmount },
      { $Type : 'UI.DataField', Value : Currency }
    ]
  },

  // ---- Object Page layout (sections) ---------------------------------------
  UI.Facets : [
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'GeneralInfoFacet',
      Label  : 'General Information',
      Target : '@UI.FieldGroup#General'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'ItemsFacet',
      Label  : 'Sales Order Items',
      Target : 'Items/@UI.LineItem'   // table facet for the composition
    }
  ]
);

// ---- Field-level labels, measures and value helps --------------------------
annotate SalesService.SalesOrders with {
  SalesOrderNo @title : 'Sales Order No';
  CustomerID   @title : 'Customer ID';
  CustomerName @title : 'Customer Name';
  OrderDate    @title : 'Order Date';
  TotalAmount  @title : 'Total Amount' @Measures.ISOCurrency : Currency;
  Currency     @title : 'Currency';

  Status @title : 'Status'
         @Common.ValueListWithFixedValues
         @Common.ValueList : {
           $Type          : 'Common.ValueListType',
           CollectionPath : 'OrderStatus',
           Parameters     : [
             { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : Status, ValueListProperty : 'code' },
             { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
           ]
         };

  Currency @Common.ValueList : {
    $Type          : 'Common.ValueListType',
    CollectionPath : 'Currencies',
    Parameters     : [
      { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : Currency, ValueListProperty : 'code' },
      { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
    ]
  };
};

/////////////////////////////////////////////////////////////////////////////
//  SALES ORDER ITEMS  –  table inside the Object Page (inline CRUD)
/////////////////////////////////////////////////////////////////////////////

annotate SalesService.SalesOrderItems with @(
  UI.LineItem : [
    { $Type : 'UI.DataField', Value : ItemNo },
    { $Type : 'UI.DataField', Value : ProductID },
    { $Type : 'UI.DataField', Value : ProductName },
    { $Type : 'UI.DataField', Value : Quantity },
    { $Type : 'UI.DataField', Value : UnitPrice },
    { $Type : 'UI.DataField', Value : NetAmount },
    { $Type : 'UI.DataField', Value : Currency }
  ],

  UI.Identification : [
    { $Type : 'UI.DataField', Value : ProductName }
  ]
);

annotate SalesService.SalesOrderItems with {
  ItemNo      @title : 'Item No';
  ProductID   @title : 'Product ID';
  ProductName @title : 'Product Name';
  Quantity    @title : 'Quantity';
  UnitPrice   @title : 'Unit Price' @Measures.ISOCurrency : Currency;
  NetAmount   @title : 'Net Amount' @Measures.ISOCurrency : Currency;
  Currency    @title : 'Currency';
};
