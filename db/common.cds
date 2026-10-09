// namespace poapplication.common;

// using { Country, Currency } from '@sap/cds/common';

// type nameStr : String(50);







namespace poapplication.common;

using { Currency } from '@sap/cds/common';

type Guid        : UUID;
type PhoneNumber : String(32);
type Email       : String(255);
type Role        : String(2);
type String32    : String(32);
type String64    : String(64);
type String255   : String(255);

type Gender : String(1) enum {
    male        = 'M';
    female      = 'F';
    undisclosed = 'D';
};

type AmountT : Decimal(10,2);

aspect Amount {
    GROSS_AMOUNT : AmountT;
    NET_AMOUNT   : AmountT;
    TAX_AMOUNT   : AmountT;
    CURRENCY     : Currency;
}

aspect Address {
    STREET      : String255;
    POSTAL_CODE : String(12);
    CITY        : String255;
    COUNTRY     : String255;
    BUILDING    : String255;
}