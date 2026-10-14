namespace poapplication.db;

using {
    cuid,
    Currency
} from '@sap/cds/common';
using {poapplication.common as common} from './common';

context master {
    entity BusinessPartners {
        key NODE_KEY     : common.Guid        @(title: '{i18n>NODE_KEY}');
            BP_ROLE      : common.Role        @(title: '{i18n>BP_ROLE}');
            EMAIL        : common.Email       @(title: '{i18n>EMAIL}');
            MOBILE       : common.PhoneNumber @(title: '{i18n>MOBILE}');
            FAX          : common.String32    @(title: '{i18n>FAX}');
            WEB          : common.String255   @(title: '{i18n>WEB}');
            BP_ID        : common.Guid        @(title: '{i18n>BP_ID}');
            COMPANY_NAME : common.String255   @(title: '{i18n>COMPANY_NAME}');
            // Managed Association
            AD           : Association to Addresses;
    }

    entity Addresses : common.Address {
        key NODE_KEY     : common.Guid     @(title: '{i18n>NODE_KEY}');
            ADDRESS_TYPE : common.String32 @(title: '{i18n>ADDRESS_TYPE}');
            VAL_START    : Date            @(title: '{i18n>VAL_START}');
            VAL_END      : Date            @(title: '{i18n>VAL_END}');
            LATITUDE     : Decimal(9, 6)   @(title: '{i18n>LATITUDE}');
            LONGITUDE    : Decimal(9, 6)   @(title: '{i18n>LONGITUDE}');
            // Back-link Association
            BP           : Association to one BusinessPartners
                               on BP.AD = $self;
    }

    entity Products {
        key NODE_KEY       : common.Guid      @(title: '{i18n>NODE_KEY}');
            PRODUCT_ID     : common.String32  @(title: '{i18n>PRODUCT_ID}');
            TYPE_CODE      : String(2)        @(title: '{i18n>TYPE_CODE}');
            CATEGORY       : common.String32  @(title: '{i18n>CATEGORY}');
            DESCRIPTION    : common.String255 @(title: '{i18n>DESCRIPTION}');
            TAX_TARIF_CODE : Integer          @(title: '{i18n>TAX_TARIF_CODE}');
            MEASURE_UNIT   : String(2)        @(title: '{i18n>MEASURE_UNIT}');
            WEIGHT_MEASURE : Decimal(5, 2)    @(title: '{i18n>WEIGHT_MEASURE}');
            WEIGHT_UNIT    : String(2)        @(title: '{i18n>WEIGHT_UNIT}');
            PRICE          : Decimal(15, 2)   @(title: '{i18n>PRICE}');
            CURRENCY_CODE  : String(5)        @(title: '{i18n>CURRENCY_CODE}');
            WIDTH          : Decimal(5, 2)    @(title: '{i18n>WIDTH}');
            DEPTH          : Decimal(5, 2)    @(title: '{i18n>DEPTH}');
            HEIGHT         : Decimal(5, 2)    @(title: '{i18n>HEIGHT}');
            DIM_UNIT       : String(2)        @(title: '{i18n>DIM_UNIT}');
            // Supplier Business Partner
            SUPPLIERS      : Association to BusinessPartners;
    }

    entity Employees : cuid {

        nameFirst     : common.String64    @(title: '{i18n>FIRST_NAME}');
        nameLast      : common.String64    @(title: '{i18n>LAST_NAME}');
        nameInitials  : common.String64    @(title: '{i18n>INITIALS}');
        nameMiddle    : common.String64    @(title: '{i18n>MIDDLE_NAME}');

        gender        : common.Gender      @(title: '{i18n>GENDER}');
        language      : String(2)          @(title: '{i18n>LANGUAGE}');
        loginName     : String(16)         @(title: '{i18n>LOGIN_NAME}');

        phoneNumber   : common.PhoneNumber @(title: '{i18n>PHONE_NUMBER}');
        email         : common.Email       @(title: '{i18n>EMAIL_ADDRESS}');

        Currency      : Currency           @(title: '{i18n>CURRENCY}');
        salaryAmount  : common.AmountT     @(title: '{i18n>SALARY_AMOUNT}');

        accountNumber : common.String32    @(title: '{i18n>ACCOUNT_NUMBER}');
        bankId        : String(16)         @(title: '{i18n>BANK_ID}');
        bankName      : common.String64    @(title: '{i18n>BANK_NAME}');
    }
    
}



context transaction {
    entity PurchaseOrders : common.Amount {
        key NODE_KEY         : common.Guid                            @(title: '{i18n>NODE_KEY}');
            // Readable IDs like 300000000 (UUID typing would break the PO ID filter)
            PO_ID            : String(36)                             @(title: '{i18n>PO_ID}');
            // Managed Association
            PARTNER          : Association to master.BusinessPartners @(title: '{i18n>PARTNER_GUID}');
            LIFECYCLE_STATUS : String(1)                              @(title: '{i18n>LIFECYCLE_STATUS}');
            OVERALL_STATUS   : String(1)                              @(title: '{i18n>OVERALL_STATUS}');
            // Unmanaged Association
            Items            : Association to many PurchaseItems
                                   on Items.PARENT = $self;
    }

    entity PurchaseItems : common.Amount {
        key NODE_KEY    : common.Guid                    @(title: '{i18n>NODE_KEY}');
            // Parent Purchase Order
            PARENT      : Association to PurchaseOrders;
            PO_ITEM_POS : Integer                        @(title: '{i18n>PO_ITEM_POS}');
            // Product Reference
            PRODUCT     : Association to master.Products @(title: '{i18n>PRODUCT_GUID}');
    }
}

entity Countries {
    key code    : String(2);
    description : String(200);
}

// Business partner role texts (BP_ROLE 1-4)
entity BPRoleFltr {
    key code        : Integer     @(title: '{i18n>BP_ROLE}');
        description : String(80)  @(title: '{i18n>BP_ROLE}');
}
