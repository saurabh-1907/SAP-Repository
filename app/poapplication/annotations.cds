using CatalogService as service from '../../srv/cat-service';

// ==================================================
// VALUE HELP - PO ID, status, Country and Company Name filters show a list to pick from
// ==================================================

annotate service.PurchaseOrderSrv with {
    PO_ID @(
        Common: {
            ValueList: {
                Label          : 'Purchase Order ID',
                CollectionPath : 'PurchaseOrderSrv',
                SearchSupported: true,
                Parameters     : [
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'PO_ID',
                        ValueListProperty: 'PO_ID'
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'COMPANY_NAME'
                    }
                ]
            }
        }
    );

    LSTEXT @(
        Common: {
            ValueList: {
                Label          : 'Life Cycle Status',
                CollectionPath : 'LifeCycleStatusSrv',
                SearchSupported: true,
                Parameters     : [
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'LSTEXT',
                        ValueListProperty: 'LSTEXT'
                    }
                ]
            }
        }
    );

    OSTEXT @(
        Common: {
            ValueList: {
                Label          : 'Overall Status',
                CollectionPath : 'OverallStatusSrv',
                SearchSupported: true,
                Parameters     : [
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'OSTEXT',
                        ValueListProperty: 'OSTEXT'
                    }
                ]
            }
        }
    );

    partnerCountryDesc @(
        Common: {
            ValueList: {
                Label          : 'Country',
                CollectionPath : 'CountriesSrv',
                SearchSupported: true,
                Parameters     : [
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'partnerCountryDesc',
                        ValueListProperty: 'description'
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'code'
                    }
                ]
            }
        }
    );

    COMPANY_NAME @(
        Common: {
            Text     : COMPANY_NAME,
            ValueList: {
                Label         : 'Company Name',
                CollectionPath: 'BusinessPartnerSrv',
                SearchSupported: true,
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'BP_ID',
                        ValueListProperty: 'BP_ID'
                    },
                    {
                        $Type            : 'Common.ValueListParameterOut',
                        LocalDataProperty: 'COMPANY_NAME',
                        ValueListProperty: 'COMPANY_NAME'
                    }
                ]
            }
        }
    )
};

annotate service.PurchaseOrderSrv with @(UI.Chart: {
    Title              : 'Status of the order',
    Description        : 'Overall lifecycle status of the order',
    ChartType          : #Column,
    Dimensions         : [
        LSC,
        OSC
    ],
    Measures           : [PO_ID],
    DimensionAttributes: [
        {
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: LSC,
            Role     : #Category
        },
        {
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: OSC,
            Role     : #Series
        }
    ],
    MeasureAttributes  : [{
        $Type  : 'UI.ChartMeasureAttributeType',
        Measure: PO_ID,
        Role   : #Axis1
    }]
});

// Lets the status chart aggregate: count orders (PO_ID) per LSC / OSC
annotate service.PurchaseOrderSrv with @(
    Aggregation.ApplySupported      : {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter'
        ],
        GroupableProperties   : [
            LSC,
            OSC,
            LSTEXT,
            OSTEXT
        ],
        AggregatableProperties: [{Property: PO_ID}]
    },
    Aggregation.CustomAggregate #PO_ID: 'Edm.Int32'
) {
    PO_ID @Aggregation.default: #COUNT_DISTINCT;
};

// ==================================================
// PURCHASE ORDER - LIST REPORT
// ==================================================

annotate service.PurchaseOrderSrv with @(

    UI.SelectionFields       : [
        PO_ID,
        COMPANY_NAME,
        LSTEXT,
        OSTEXT,
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
            $Type: 'UI.DataField',
            Value: CITY
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
                    Target: '@UI.FieldGroup#BPAmtInfo'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'AddressInfo',
                    Label : 'Address Information',
                    Target: '@UI.FieldGroup#BPAddrInfo'
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Status Overview',
            Target: '@UI.Chart'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'POItems',
            Label : 'Purchase Item Details',
            Target: 'Items/@UI.LineItem'
        }
    ],

    UI.FieldGroup #BPAmtInfo : {
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

    UI.FieldGroup #BPAddrInfo: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: STREET
            },
            {
                $Type: 'UI.DataField',
                Value: BUILDING
            },
            {
                $Type: 'UI.DataField',
                Value: CITY
            },
            {
                $Type: 'UI.DataField',
                Value: POSTAL_CODE
            },
            {
                $Type: 'UI.DataField',
                Value: partnerCountryDesc
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
    UI.SelectionFields : [
        PO_ITEM_POS,
        PRODUCT.DESCRIPTION
    ],

    UI.LineItem  : [
        {
            $Type: 'UI.DataField',
            Value: PO_ITEM_POS
        },
        {
            $Type: 'UI.DataField',
            Value: PRODUCT_NODE_KEY
        },
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
        }
    ],

    UI.HeaderInfo: {
        TypeName      : 'Purchase Item',
        TypeNamePlural: 'Purchase Items',
        Title         : {
            $Type: 'UI.DataField',
            Value: PO_ITEM_POS
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: PRODUCT.DESCRIPTION
        }
    },

    UI.Facets    : [
        {
            $Type : 'UI.CollectionFacet',
            Label : 'Product Details',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Product Information',
                    Target: '@UI.FieldGroup#ProductInfo'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Product Supplier Information',
                    Target: '@UI.FieldGroup#ProductItemInfo'
                }
            ]
        }
    ],

    UI.FieldGroup #ProductInfo    : {
        Data: [
            { $Type: 'UI.DataField', Value: PRODUCT.DESCRIPTION },
            { $Type: 'UI.DataField', Value: PRODUCT.DEPTH },
            { $Type: 'UI.DataField', Value: PRODUCT.WIDTH },
            { $Type: 'UI.DataField', Value: PRODUCT.HEIGHT },
            { $Type: 'UI.DataField', Value: PRODUCT.PRICE },
            { $Type: 'UI.DataField', Value: PRODUCT.CATEGORY },
            { $Type: 'UI.DataField', Value: PRODUCT.MEASURE_UNIT },
            { $Type: 'UI.DataField', Value: PRODUCT.CURRENCY_CODE }
        ]
    },

    UI.FieldGroup #ProductItemInfo: {
        Data: [
            { $Type: 'UI.DataField', Value: CURRENCY_code },
            { $Type: 'UI.DataField', Value: GROSS_AMOUNT },
            { $Type: 'UI.DataField', Value: NET_AMOUNT },
            { $Type: 'UI.DataField', Value: TAX_AMOUNT }
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


// Labels for the Country value help
annotate service.CountriesSrv with {
    code        @title: 'Country Code';
    description @title: '{i18n>COUNTRY}';
};
