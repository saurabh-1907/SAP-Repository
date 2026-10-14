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

    entity EmployeeSrv
    as projection on database.master.Employees actions {

        action increaseSalaryBy10Percent()
            returns String;
    };

    entity ProductSrv
    as projection on database.master.Products actions {

        action increasePriceBy10Percent()
            returns String;

        function getTop20Products()
            returns array of ProductSrv;
    };

    entity BusinessPartnerSrv
    as projection on database.master.BusinessPartners;

    entity AddressSrv
    as projection on database.master.Addresses;

    entity PurchaseOrderSrv
    as projection on database.transaction.PurchaseOrders {
        *,
        case LIFECYCLE_STATUS
            when 'N' then 'Not Started'
            when 'I' then 'In Progress'
            when 'C' then 'Completed'
            else 'Unknown'
        end as LifeCycleStatus : String(20),
        case LIFECYCLE_STATUS
            when 'N' then 2
            when 'I' then 0
            when 'C' then 3
            else 0
        end as LifeCycleCriticality : Integer,
        case OVERALL_STATUS
            when 'P' then 'Processed'
            when 'N' then 'New'
            when 'X' then 'Rejected'
            else 'Unknown'
        end as OverallStatus : String(20),
        case OVERALL_STATUS
            when 'P' then 3
            when 'N' then 2
            when 'X' then 1
            else 0
        end as OverallCriticality : Integer
    } actions {

        @Common.SideEffects: {
            TargetProperties: ['in/GROSS_AMOUNT', 'in/NET_AMOUNT', 'in/TAX_AMOUNT']
        }
        action discount()
            returns PurchaseOrderSrv;
    };

    entity PurchaseItemSrv
    as projection on database.transaction.PurchaseItems;

    action createEmployee(
        ID            : UUID,
        Currency_code : String(3),
        accountNumber : common.String32,
        bankId        : String(16),
        bankName      : common.String64,
        email         : common.Email,
        gender        : common.Gender,
        language      : String(2),
        loginName     : String(16),
        nameFirst     : common.String64,
        nameInitials  : String,
        nameLast      : String,
        nameMiddle    : String,
        phoneNumber   : String,
        salaryAmount  : Decimal(15,2)
    );

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

    action updateEmployee(
        ID            : UUID,
        salaryAmount  : common.AmountT,
        Currency_code : String(3)
    ) returns String;

    action updateAddress(
        NODE_KEY     : UUID,
        ADDRESS_TYPE : common.String32,
        CITY         : String
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

    function getHighestPriceProducts()
        returns array of ProductSrv;

    function getUtilities() returns String;
}