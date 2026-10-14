using { poapplication.db as database } from '../db/schema';
using { poapplication.common as common } from '../db/common';

type UtilityResult {
    uuid         : String;
    uri          : String;
    isFileExists : Boolean;
    dirExists    : Boolean;
    packageInfo  : LargeString;
}

service CatalogService {

    // ==================================================
    // MASTER DATA
    // ==================================================

    entity EmployeeSrv
    as projection on database.master.Employees {
        *
    } actions {

        // +15% (class version)
        action increaseSalary()
            returns array of EmployeeSrv;

        function Top20PaidEmployee()
            returns array of EmployeeSrv;

        // +10%
        action increaseSalaryBy10Percent()
            returns String;
    };

    entity ProductSrv
    as projection on database.master.Products {
        *
    } actions {

        // +10% (class version)
        action increasePrice()
            returns array of ProductSrv;

        function top_20_product()
            returns array of ProductSrv;

        action increasePriceBy10Percent()
            returns String;

        function getTop20Products()
            returns array of ProductSrv;
    };

    entity BusinessPartnerSrv
    as projection on database.master.BusinessPartners;

    entity AddressSrv
    as projection on database.master.Addresses;

    // ==================================================
    // TRANSACTION DATA
    // ==================================================

    @Capabilities: {
        DeleteRestrictions: {
            $Type    : 'Capabilities.DeleteRestrictionsType',
            Deletable: false
        },
        UpdateRestrictions: {
            $Type    : 'Capabilities.UpdateRestrictionsType',
            Updatable: false
        },
        InsertRestrictions: {
            $Type     : 'Capabilities.InsertRestrictionsType',
            Insertable: false
        }
    }

    entity PurchaseOrderSrv as
        select from database.transaction.PurchaseOrders as po

        inner join database.master.BusinessPartners as bp
            on bp.NODE_KEY = po.PARTNER.NODE_KEY

        inner join database.master.Addresses as addr
            on addr.NODE_KEY = bp.AD.NODE_KEY

        inner join database.Countries as country
            on addr.COUNTRY = country.code

        {
            key po.NODE_KEY,

                po.PO_ID,
                po.GROSS_AMOUNT,
                po.NET_AMOUNT,
                po.TAX_AMOUNT,
                po.CURRENCY,

                bp.COMPANY_NAME,
                bp.BP_ID,
                bp.BP_ROLE,
                bp.MOBILE,
                bp.FAX,
                bp.EMAIL,
                bp.WEB,

                addr.ADDRESS_TYPE,
                addr.BUILDING,
                addr.CITY,
                addr.COUNTRY,
                addr.LATITUDE,
                addr.LONGITUDE,
                addr.STREET,
                addr.POSTAL_CODE,

                po.Items,

                bp.COMPANY_NAME     as partnerName,
                bp.BP_ID            as partnerId,
                addr.COUNTRY        as partnerCountry,

                country.description as partnerCountryDesc @(title: '{i18n>COUNTRY}'),

                case
                    po.LIFECYCLE_STATUS
                    when 'N'
                         then 2
                    when 'S'
                         then 3
                    when 'C'
                         then 3
                    else 1
                end                 as LSC    : Integer,

                case
                    po.OVERALL_STATUS
                    when 'R'
                         then 1
                    when 'P'
                         then 3
                    when 'D'
                         then 3
                    else 2
                end                 as OSC    : Integer,

                case
                    po.LIFECYCLE_STATUS
                    when 'N'
                         then 'Not Started'
                    when 'S'
                         then 'Started'
                    when 'C'
                         then 'Completed'
                    else 'Cancelled'
                end                 as LSTEXT : String(20)
                                                          @(title: '{i18n>LIFECYCLE_STATUS}'),

                case
                    po.OVERALL_STATUS
                    when 'R'
                         then 'Returned'
                    when 'P'
                         then 'Processed'
                    when 'D'
                         then 'Delivered'
                    else 'New'
                end                 as OSTEXT : String(20)
                                                          @(title: '{i18n>OVERALL_STATUS}'),

                // Header image of the object page
                'https://upload.wikimedia.org/wikipedia/commons/4/4a/Amazon_icon.svg'
                                    as ImageUrl : String(255)
        }

        actions {

            // Inline "Discount" button: gross -1000, net -800, tax -200 (class version)
            action   discountPrice() returns array of PurchaseOrderSrv;

            // Top 5 orders by gross amount
            function largestOrder()  returns array of PurchaseOrderSrv;

            // 10% off gross, net and tax
            @Common.SideEffects: {
                TargetProperties: ['in/GROSS_AMOUNT', 'in/NET_AMOUNT', 'in/TAX_AMOUNT']
            }
            action   discount()      returns PurchaseOrderSrv;
        };

    entity PurchaseItemSrv
    as projection on database.transaction.PurchaseItems;

    // ==================================================
    // UNBOUND ACTIONS
    // ==================================================

    action createEmployee(
        Currency_code : String(3)          @title: '{i18n>CURRENCY}',
        ID            : UUID               @title: '{i18n>EMPLOYEE_ID}',
        accountNumber : common.String32    @title: '{i18n>ACCOUNT_NUMBER}',
        bankId        : String(16)         @title: '{i18n>BANK_ID}',
        bankName      : common.String64    @title: '{i18n>BANK_NAME}',
        email         : common.Email       @title: '{i18n>EMAIL}',
        gender        : common.Gender      @title: '{i18n>GENDER}',
        language      : String(2)          @title: '{i18n>LANGUAGE}',
        loginName     : String(16)         @title: '{i18n>LOGIN_NAME}',
        nameFirst     : common.String64    @title: '{i18n>FIRST_NAME}',
        nameInitials  : common.String64    @title: '{i18n>INITIALS}',
        nameLast      : common.String64    @title: '{i18n>LAST_NAME}',
        nameMiddle    : common.String64    @title: '{i18n>MIDDLE_NAME}',
        phoneNumber   : common.PhoneNumber @title: '{i18n>PHONE_NUMBER}',
        salaryAmount  : common.AmountT     @title: '{i18n>SALARY_AMOUNT}'
    ) returns array of EmployeeSrv;

    action createAddressSrv(
        NODE_KEY     : UUID,
        ADDRESS_TYPE : common.String32,
        VAL_START    : Date,
        VAL_END      : Date,
        LATITUDE     : Decimal(9,6),
        LONGITUDE    : Decimal(9,6),
        STREET       : common.String255,
        POSTAL_CODE  : common.String32,
        CITY         : common.String255,
        COUNTRY      : common.String255,
        BUILDING     : common.String255
    ) returns array of AddressSrv;

    action createAddress(
        NODE_KEY     : UUID,
        ADDRESS_TYPE : String(32),
        VAL_START    : Date,
        VAL_END      : Date,
        LATITUDE     : Decimal(9,6),
        LONGITUDE    : Decimal(9,6),
        CITY         : String,
        STREET       : String,
        POSTAL_CODE  : String,
        COUNTRY      : String
    );

    action createProduct(
        NODE_KEY       : common.Guid,
        PRODUCT_ID     : common.String32,
        TYPE_CODE      : String(2),
        CATEGORY       : common.String32,
        DESCRIPTION    : common.String255,
        TAX_TARIF_CODE : Integer,
        MEASURE_UNIT   : String(2),
        WEIGHT_MEASURE : Decimal(5,2),
        WEIGHT_UNIT    : String(2),
        PRICE          : Decimal(15,2),
        CURRENCY_CODE  : String(5),
        WIDTH          : Decimal(5,2),
        DEPTH          : Decimal(5,2),
        HEIGHT         : Decimal(5,2),
        DIM_UNIT       : String(2)
    ) returns array of ProductSrv;

    action updateEmployee(
        ID            : UUID,
        salaryAmount  : common.AmountT,
        Currency_code : String(3)
    ) returns String;

    action updateAddress(
        NODE_KEY     : UUID,
        ADDRESS_TYPE : common.String32,
        CITY         : common.String255
    ) returns String;

    action updateProductPrice(
        NODE_KEY : common.Guid,
        PRICE    : Decimal(15,2)
    ) returns String;

    action updateProduct(
        NODE_KEY      : UUID,
        PRICE         : Decimal(15,2),
        CURRENCY_CODE : String(5)
    ) returns String;

    action deleteEmployee(ID : UUID)
        returns String;

    function getHighestSalariedEmployees()
        returns array of EmployeeSrv;

    function getHeighestPricedProduct()
        returns array of ProductSrv;

    function getHighestPriceProducts()
        returns array of ProductSrv;

    function getUtilities() returns String;
}
