using CatalogService as service from '../../srv/cat-service';

// ==================================================
// PURCHASE ORDER - LIST REPORT + OBJECT PAGE
// ==================================================

annotate service.PurchaseOrderSrv with @(

    UI.SelectionFields : [
        PO_ID,
        PARTNER.COMPANY_NAME,
        GROSS_AMOUNT,
        PARTNER.ADDRESS.COUNTRY
    ],

    UI.LineItem : [
        { $Type : 'UI.DataField', Value : PO_ID },
        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'CatalogService.discount',
            Label  : 'Discount',
            Inline : true
        },
        { $Type : 'UI.DataField', Value : PARTNER.COMPANY_NAME },
        { $Type : 'UI.DataField', Value : GROSS_AMOUNT },
        { $Type : 'UI.DataField', Value : CURRENCY_code },
        {
            $Type       : 'UI.DataField',
            Value       : LifeCycleStatus,
            Criticality : LifeCycleCriticality
        },
        {
            $Type       : 'UI.DataField',
            Value       : OverallStatus,
            Criticality : OverallCriticality
        },
        { $Type : 'UI.DataField', Value : PARTNER.ADDRESS.COUNTRY }
    ],

    UI.HeaderInfo : {
        TypeName       : 'Purchase Order',
        TypeNamePlural : 'Purchase Orders',
        Title          : { Value : PO_ID },
        Description    : { Value : PARTNER.COMPANY_NAME }
    },

    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneralInfo',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#General'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'PricingInfo',
            Label  : 'Pricing',
            Target : '@UI.FieldGroup#Pricing'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'POItems',
            Label  : 'PO Items',
            Target : 'Items/@UI.LineItem'
        }
    ],

    UI.FieldGroup #General : {
        Data : [
            { Value : PO_ID },
            { Value : PARTNER.COMPANY_NAME },
            { Value : PARTNER.ADDRESS.COUNTRY },
            { Value : LifeCycleStatus, Criticality : LifeCycleCriticality },
            { Value : OverallStatus,   Criticality : OverallCriticality }
        ]
    },

    UI.FieldGroup #Pricing : {
        Data : [
            { Value : GROSS_AMOUNT },
            { Value : NET_AMOUNT },
            { Value : TAX_AMOUNT },
            { Value : CURRENCY_code }
        ]
    }
);

annotate service.PurchaseOrderSrv with {
    PO_ID                @title : 'Purchase Order ID';
    GROSS_AMOUNT         @title : 'Gross Amount'  @Measures.ISOCurrency : CURRENCY_code;
    NET_AMOUNT           @title : 'Net Amount'    @Measures.ISOCurrency : CURRENCY_code;
    TAX_AMOUNT           @title : 'Tax Amount'    @Measures.ISOCurrency : CURRENCY_code;
    CURRENCY             @title : 'Currency';
    LifeCycleStatus      @title : 'Life Cycle Status';
    OverallStatus        @title : 'Overall Status';
    LifeCycleCriticality @UI.Hidden;
    OverallCriticality   @UI.Hidden;
    NODE_KEY             @UI.Hidden;
    PARTNER              @UI.Hidden;
};

annotate service.BusinessPartnerSrv with {
    COMPANY_NAME @title : 'Company Name';
};

annotate service.AddressSrv with {
    COUNTRY @title : 'Country';
};

// ==================================================
// PURCHASE ITEMS - TABLE ON OBJECT PAGE
// ==================================================

annotate service.PurchaseItemSrv with @(
    UI.LineItem : [
        { Value : PO_ITEM_POS },
        { Value : PRODUCT.PRODUCT_ID },
        { Value : PRODUCT.DESCRIPTION },
        { Value : PRODUCT.CATEGORY },
        { Value : GROSS_AMOUNT },
        { Value : CURRENCY_code }
    ]
);

annotate service.PurchaseItemSrv with {
    PO_ITEM_POS  @title : 'Item Position';
    GROSS_AMOUNT @title : 'Gross Amount' @Measures.ISOCurrency : CURRENCY_code;
};

annotate service.ProductSrv with {
    PRODUCT_ID  @title : 'Product ID';
    DESCRIPTION @title : 'Description';
    CATEGORY    @title : 'Category';
};
