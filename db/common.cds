namespace poapplication.common;

using { Currency } from '@sap/cds/common';

type Guid : UUID;
type PhoneNumber : String(32);
type Email : String(255);
type Role : String(2);
type String32 : String(32);
type String64 : String(64);
type String255 : String(255);

type Gender : String(1) enum {
    male        = 'M';
    female      = 'F';
    undisclosed = 'D';
}

type AmountT : Decimal(10,2) @(
    Semantics.amount.currencyCode : 'CURRENCY_CODE',
    sap.unit : 'CURRENCY_CODE'
);

aspect Amount {
    GROSS_AMOUNT : AmountT @(title: '{i18n>GROSS_AMOUNT}');
    NET_AMOUNT   : AmountT @(title: '{i18n>NET_AMOUNT}');
    TAX_AMOUNT   : AmountT @(title: '{i18n>TAX_AMOUNT}');
    CURRENCY     : Currency @(title: '{i18n>CURRENCY_CODE}');
}

aspect Address {
    STREET      : String255 @(title: '{i18n>STREET}');
    POSTAL_CODE : String(12) @(title: '{i18n>POSTAL}');
    CITY        : String255 @(title: '{i18n>CITY}');
    COUNTRY     : String255 @(title:'{i18n>COUNTRY}');
    BUILDING    : String255 @(title:'{i18n>BUILDING}');
}
    