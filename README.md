# Sales Order CAP (Node.js) + SAP Fiori Elements

A complete SAP Cloud Application Programming (CAP) project that manages **Sales Orders**
and **Sales Order Items** with an **OData V4** service and an **SAP Fiori Elements**
List Report + Object Page UI. Local persistence uses **SQLite**.

## Project structure

```
sales-order-cap/
├── db/
│   ├── schema.cds                       # CDS data model (entities + composition)
│   └── data/                            # Sample data (auto-deployed to SQLite)
│       ├── sales.SalesOrders.csv        # 5 orders
│       ├── sales.SalesOrderItems.csv    # 15 items
│       ├── sales.OrderStatus.csv        # Status value help
│       └── sap.common.Currencies.csv    # Currency value help
├── srv/
│   ├── service.cds                      # OData V4 SalesService (draft enabled)
│   └── service.js                       # Validation + NetAmount/TotalAmount logic
├── app/
│   ├── annotations.cds                  # Fiori Elements UI annotations
│   └── salesorders/webapp/              # Freestyle Fiori Elements app (manifest driven)
├── test/sales.http                      # Ready-made CRUD requests
└── package.json                         # Deps + cds config (sqlite)
```

## Prerequisites

```bash
npm i -g @sap/cds-dk      # provides the `cds` CLI
node -v                   # Node 18+ recommended
```

## Run locally

```bash
cd sales-order-cap
npm install
cds watch
```

`cds watch` starts the server on **http://localhost:4004**, compiles the model,
deploys an **in-memory SQLite** database and loads the CSV sample data on every
restart. The terminal prints the service endpoints.

- Service root:    http://localhost:4004/odata/v4/sales
- Metadata:        http://localhost:4004/odata/v4/sales/$metadata
- Fiori preview:   open http://localhost:4004 → **Fiori preview** link next to
  `SalesOrders` (CAP's auto-generated, zero-config UI — always works locally)
- **App (direct):**     http://localhost:4004/salesorders/webapp/index.html
- **App (Launchpad):**  http://localhost:4004/flp.html  ← tile-based Fiori Launchpad

> Note on UI5 source: the app (`index.html`) and the Launchpad (`flp.html`) load UI5
> from `https://sapui5.hana.ondemand.com` — the **same CDN CAP's Fiori preview uses** —
> so the app renders wherever the preview does. CAP does not serve UI5 locally.

To persist to a file-based DB instead of in-memory:

```bash
cds deploy --to sqlite:db.sqlite
cds watch
```

## Test CRUD operations

Open `test/sales.http` in VS Code (REST Client extension) and click **Send Request**,
or use curl. Highlights:

- **Read**: `GET /SalesOrders?$expand=Items`
- **Deep insert** (order + items in one POST): request #4 — `TotalAmount` and each
  `NetAmount` are computed server-side.
- **Validation**: request #5 (Quantity ≤ 0) and #6 (duplicate `SalesOrderNo`) return HTTP 400.
- **Update**: `PATCH /SalesOrders(<ID>)`
- **Delete**: `DELETE /SalesOrders(<ID>)` — cascades to items via the composition.

## How Fiori Elements consumes the OData service

SAP Fiori Elements is **metadata driven**: the templates (List Report, Object Page)
render entirely from the OData `$metadata`, which includes the `UI.*` and `Common.*`
annotations defined in `app/annotations.cds`.

- `UI.SelectionFields` → filter bar fields
- `UI.LineItem` (SalesOrders) → List Report table columns + Object Page item table
- `UI.HeaderInfo` → Object Page header title/description
- `UI.FieldGroup` + `UI.Facets` → Object Page "General Information" section and the
  "Sales Order Items" table facet
- `UI.Identification` → default title-area content
- `Common.ValueList` → F4 value helps for `Status` and `Currency`
- `@odata.draft.enabled` on `SalesOrders` gives Create/Edit with **draft** handling;
  because `Items` is a **Composition**, inline create/edit/delete of items works inside
  the Object Page and is saved atomically with the header.

The app's `manifest.json` points `mainService` at `/odata/v4/sales/` and uses the
`sap.fe.templates.ListReport` / `sap.fe.templates.ObjectPage` components — no custom
controller code is required.
```
