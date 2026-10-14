# Getting Started

Welcome to your new CAP project.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | content for UI frontends goes here
`db/` | your domain models and data go here
`srv/` | your service models and code go here
`readme.md` | this getting started guide

## Next Steps

- Open a new terminal and run `cds watch`
- (in VS Code simply choose _**Terminal** > Run Task > cds watch_)
- Start with your domain model, in a CDS file in `db/`

## Learn More

Learn more at <https://cap.cloud.sap>.

## Purchase Order Application

Aligned with the class reference project (rishabhsinha3010/SAP-Repo): same data model
(i18n labels, `BusinessPartners.AD`, `Countries`, `db/CDSView.cds`), the same
`PurchaseOrderSrv` join view, the class actions, the same list report and header
annotations, and the MTA deployment files.

Run locally: `npm install`, then `cds watch` and open `/poapplication.poapplication/index.html`.

### Additions on top of the class project

| Area | Addition |
|---|---|
| Data | Seed CSVs for every entity (business partners, addresses, countries, products, 20 purchase orders, items, employees) |
| Data model | `PO_ID` is `String(36)` instead of UUID so IDs like `300000000` can be filtered; `Countries.code` is a key so HANA can load its CSV |
| Service | `ImageUrl` field on `PurchaseOrderSrv` for the header image |
| Service | `discount()` action: 10% off gross, net and tax (toolbar button "Discount 10%") |
| Service | `discountPrice` updates the base table (the join view is not updatable) and rejects orders below 1000 |
| Service | Extra actions: `increaseSalaryBy10Percent`, `increasePriceBy10Percent`, `getTop20Products`, `createAddress`, `updateProduct`, `getHighestPriceProducts` |
| Service | Validations: purchase item amount/position, address country, employee phone and salary, company name |
| UI | Object page body: General Information, Pricing and PO Items sections |
| UI | Purchase item object page (header, item details) |
| Security | `.env` is git-ignored so `VCAP_SERVICES` credentials are never committed |
