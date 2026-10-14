using CatalogService as service from '../../srv/cat-service';
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

