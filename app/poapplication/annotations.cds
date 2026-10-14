using CatalogService as service from '../../srv/cat-service';

// ==================================================
// PURCHASE ORDER - LIST REPORT
// ==================================================

annotate service.PurchaseOrderSrv with @(

    UI.SelectionFields       : [
        PO_ID,
        COMPANY_NAME,
        GROSS_AMOUNT,
        partnerCountryDesc
    ],

    UI.LineItem              : [
        {
            $Type: 'UI.DataField',
            Value: PO_ID
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'CatalogService.discountPrice',
            Label : 'Discount',
            Inline: true
        },
        // Extra: toolbar button, applies 10% to the selected order
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'CatalogService.discount',
            Label : 'Discount 10%'
        },
        {
            $Type: 'UI.DataField',
            Value: COMPANY_NAME
        },
        {
            $Type: 'UI.DataField',
            Value: GROSS_AMOUNT
        },
        {
            $Type: 'UI.DataField',
            Value: CURRENCY_code
        },
        {
            $Type      : 'UI.DataField',
            Value      : LSTEXT,
            Criticality: LSC
        },
        {
            $Type      : 'UI.DataField',
            Value      : OSTEXT,
            Criticality: OSC
        },
        {
            $Type: 'UI.DataField',
            Value: partnerCountryDesc
        }
    ],

// ==================================================
// PURCHASE ORDER - OBJECT PAGE HEADER
// ==================================================

    UI.HeaderInfo            : {
        TypeName      : 'Purchase Order',
        TypeNamePlural: 'Purchase Orders',
        Title         : {
            $Type: 'UI.DataField',
            Value: PO_ID
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: COMPANY_NAME
        },
        // Image link comes from the ImageUrl field of PurchaseOrderSrv
        ImageUrl      : ImageUrl
    },

    UI.HeaderFacets          : [
        {
            $Type : 'UI.CollectionFacet',
            Label : 'Business Partner Details',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'General Information',
                    Target: '@UI.FieldGroup#BPInfo'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Communication Information',
                    Target: '@UI.FieldGroup#BPCommInfo'
                }
            ]
        }
    ],

    UI.FieldGroup #BPInfo    : {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: BP_ID
            },
            {
                $Type: 'UI.DataField',
                Value: COMPANY_NAME
            },
            {
                $Type: 'UI.DataField',
                Value: BP_ROLE
            }
        ]
    },

    UI.FieldGroup #BPCommInfo: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: EMAIL
            },
            {
                $Type: 'UI.DataField',
                Value: MOBILE
            },
            {
                $Type: 'UI.DataField',
                Value: FAX
            }
        ]
    },

// ==================================================
// PURCHASE ORDER - OBJECT PAGE BODY
// ==================================================

    UI.Facets                : [
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'OtherDetails',
            Label : 'Other details',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'AmountInfo',
                    Label : 'Amount Information',
                    Target: '@UI.FieldGroup#AmountInfo'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'AddressInfo',
                    Label : 'Address Information',
                    Target: '@UI.FieldGroup#AddressInfo'
                }
            ]
        },
        // Extra: items of the order
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'POItems',
            Label : 'PO Items',
            Target: 'Items/@UI.LineItem'
        }
    ],

    UI.FieldGroup #AmountInfo: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: GROSS_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: NET_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: TAX_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: CURRENCY_code
            }
        ]
    },

    UI.FieldGroup #AddressInfo: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: COMPANY_NAME
            },
            {
                $Type: 'UI.DataField',
                Value: BUILDING
            },
            {
                $Type: 'UI.DataField',
                Value: STREET
            },
            {
                $Type: 'UI.DataField',
                Value: CITY
            }
        ]
    }
);

annotate service.PurchaseOrderSrv with {
    LSC      @UI.Hidden;
    OSC      @UI.Hidden;
    NODE_KEY @UI.Hidden;
    ImageUrl @UI.IsImageURL  @UI.Hidden;
};

// ==================================================
// PURCHASE ITEMS - TABLE + ITEM OBJECT PAGE (extra)
// ==================================================

annotate service.PurchaseItemSrv with @(
    UI.HeaderInfo: {
        TypeName      : 'Purchase Item',
        TypeNamePlural: 'Purchase Items',
        Title         : { Value: PRODUCT.DESCRIPTION },
        Description   : { Value: PO_ITEM_POS }
    },

    UI.LineItem  : [
        { Value: PO_ITEM_POS },
        { Value: PRODUCT.PRODUCT_ID },
        { Value: PRODUCT.DESCRIPTION },
        { Value: PRODUCT.CATEGORY },
        { Value: GROSS_AMOUNT },
        { Value: CURRENCY_code }
    ],

    UI.Facets    : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ItemInfo',
            Label : 'Item Details',
            Target: '@UI.FieldGroup#ItemInfo'
        }
    ],

    UI.FieldGroup #ItemInfo: {
        Data: [
            { Value: PO_ITEM_POS },
            { Value: PRODUCT.PRODUCT_ID },
            { Value: PRODUCT.DESCRIPTION },
            { Value: PRODUCT.CATEGORY },
            { Value: GROSS_AMOUNT },
            { Value: NET_AMOUNT },
            { Value: TAX_AMOUNT },
            { Value: CURRENCY_code }
        ]
    }
);

annotate service.PurchaseItemSrv with {
    PO_ITEM_POS @title: '{i18n>PO_ITEMS_POS}';
    NODE_KEY    @UI.Hidden;
};

// ==================================================
// EMPLOYEE - field labels (class version)
// ==================================================

annotate service.EmployeeSrv with {
    ID            @title: '{i18n>EMPLOYEE_ID}';
    nameFirst     @title: '{i18n>FIRST_NAME}';
    nameLast      @title: '{i18n>LAST_NAME}';
    email         @title: '{i18n>EMAIL}';
    accountNumber @title: '{i18n>ACCOUNT_NUMBER}';
    bankId        @title: '{i18n>BANK_ID}';
    bankName      @title: '{i18n>BANK_NAME}';
    language      @title: '{i18n>LANGUAGE}';
    gender        @title: '{i18n>GENDER}';
    loginName     @title: '{i18n>LOGIN_NAME}';
    Currency      @title: '{i18n>CURRENCY}';
};

// ==================================================
// EMPLOYEE (generated)
// ==================================================

annotate service.EmployeeSrv with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'nameFirst',
                Value : nameFirst,
            },
            {
                $Type : 'UI.DataField',
                Label : 'nameLast',
                Value : nameLast,
            },
            {
                $Type : 'UI.DataField',
                Label : 'nameInitials',
                Value : nameInitials,
            },
            {
                $Type : 'UI.DataField',
                Label : 'nameMiddle',
                Value : nameMiddle,
            },
            {
                $Type : 'UI.DataField',
                Label : 'gender',
                Value : gender,
            },
            {
                $Type : 'UI.DataField',
                Label : 'language',
                Value : language,
            },
            {
                $Type : 'UI.DataField',
                Label : 'loginName',
                Value : loginName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'phoneNumber',
                Value : phoneNumber,
            },
            {
                $Type : 'UI.DataField',
                Label : 'email',
                Value : email,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Currency_code',
                Value : Currency_code,
            },
            {
                $Type : 'UI.DataField',
                Label : 'salaryAmount',
                Value : salaryAmount,
            },
            {
                $Type : 'UI.DataField',
                Label : 'accountNumber',
                Value : accountNumber,
            },
            {
                $Type : 'UI.DataField',
                Label : 'bankId',
                Value : bankId,
            },
            {
                $Type : 'UI.DataField',
                Label : 'bankName',
                Value : bankName,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'nameFirst',
            Value : nameFirst,
        },
        {
            $Type : 'UI.DataField',
            Label : 'nameLast',
            Value : nameLast,
        },
        {
            $Type : 'UI.DataField',
            Label : 'nameInitials',
            Value : nameInitials,
        },
        {
            $Type : 'UI.DataField',
            Label : 'nameMiddle',
            Value : nameMiddle,
        },
        {
            $Type : 'UI.DataField',
            Label : 'gender',
            Value : gender,
        },
    ],
);

