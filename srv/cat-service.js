import cds from '@sap/cds';
import { existsSync, mkdirSync, readFileSync } from 'fs';
import { randomUUID } from 'crypto';

const { INSERT, SELECT, UPDATE, DELETE } = cds.ql;

export default cds.service.impl(async function () {

    const {
        EmployeeSrv,
        ProductSrv,
        BusinessPartnerSrv,
        AddressSrv,
        PurchaseOrderSrv,
        PurchaseItemSrv
    } = this.entities;

    // ==================================================
    // PURCHASE ITEM VALIDATION
    // ==================================================

    this.before(['CREATE', 'UPDATE'], PurchaseItemSrv, async (req) => {

        const {
            GROSS_AMOUNT,
            CURRENCY_CODE,
            PO_ITEM_POS
        } = req.data;

        if (
            (CURRENCY_CODE === 'USD' && GROSS_AMOUNT > 50000) ||
            (CURRENCY_CODE === 'EUR' && GROSS_AMOUNT > 10000)
        ) {
            req.reject(
                400,
                'Gross amount exceeds the allowed limit.'
            );
        }

        if (
            PO_ITEM_POS &&
            PO_ITEM_POS % 10 !== 0
        ) {
            req.reject(
                400,
                'Purchase item position must be a multiple of 10.'
            );
        }

    });

    // ==================================================
    // ADDRESS VALIDATION
    // ==================================================

    this.before('UPDATE', AddressSrv, async (req) => {

        const { COUNTRY } = req.data;

        if (
            COUNTRY &&
            !['GB', 'US'].includes(COUNTRY.toUpperCase())
        ) {
            req.reject(
                400,
                'Country must be GB or US.'
            );
        }

    });

    // ==================================================
    // PHONE VALIDATION
    // ==================================================

    this.before('UPDATE', EmployeeSrv, async (req) => {

        const { phoneNumber } = req.data;

        if (
            phoneNumber &&
            !phoneNumber.startsWith('+1') &&
            !phoneNumber.startsWith('+44')
        ) {
            req.reject(
                400,
                'Mobile number must start with +1 or +44.'
            );
        }

    });

    // ==================================================
    // SALARY VALIDATION
    // ==================================================

    this.before('UPDATE', EmployeeSrv, async (req) => {

        const { salaryAmount } = req.data;

        if (
            salaryAmount &&
            salaryAmount > 100000
        ) {
            req.reject(
                400,
                'Please get manager approval before updating salary.'
            );
        }

    });

    // ==================================================
    // BUSINESS PARTNER VALIDATION
    // ==================================================

    this.before('UPDATE', BusinessPartnerSrv, async (req) => {

        const { COMPANY_NAME } = req.data;

        if (
            COMPANY_NAME &&
            !/^[a-zA-Z0-9 ]+$/.test(COMPANY_NAME)
        ) {
            req.reject(
                400,
                'Company name must not contain special characters.'
            );
        }

    });

    // ==================================================
    // CREATE EMPLOYEE
    // ==================================================

    this.on('createEmployee', async (req) => {

        const employee = req.data;

        await INSERT.into(EmployeeSrv).entries({
            ID: employee.ID,
            Currency_code: employee.Currency_code,
            accountNumber: employee.accountNumber,
            bankId: employee.bankId,
            bankName: employee.bankName,
            email: employee.email,
            gender: employee.gender,
            language: employee.language,
            loginName: employee.loginName,
            nameFirst: employee.nameFirst,
            nameInitials: employee.nameInitials,
            nameLast: employee.nameLast,
            nameMiddle: employee.nameMiddle,
            phoneNumber: employee.phoneNumber,
            salaryAmount: employee.salaryAmount
        });

        return 'Employee created successfully';

    });

    // ==================================================
    // CREATE ADDRESS
    // ==================================================

    this.on('createAddress', async (req) => {

        await INSERT.into(AddressSrv)
            .entries(req.data);

        return 'Address created successfully';

    });

    // ==================================================
    // UPDATE EMPLOYEE
    // ==================================================

    this.on('updateEmployee', async (req) => {

        const {
            ID,
            salaryAmount,
            Currency_code
        } = req.data;

        await UPDATE(EmployeeSrv)
            .set({
                salaryAmount,
                Currency_code
            })
            .where({ ID });

        return 'Employee updated successfully';

    });

    // ==================================================
    // UPDATE ADDRESS
    // ==================================================

    this.on('updateAddress', async (req) => {

        const {
            NODE_KEY,
            ADDRESS_TYPE,
            CITY
        } = req.data;

        await UPDATE(AddressSrv)
            .set({
                ADDRESS_TYPE,
                CITY
            })
            .where({ NODE_KEY });

        return 'Address updated successfully';

    });

    // ==================================================
    // UPDATE PRODUCT
    // ==================================================

    this.on('updateProduct', async (req) => {

        const {
            NODE_KEY,
            PRICE,
            CURRENCY_CODE
        } = req.data;

        await UPDATE(ProductSrv)
            .set({
                PRICE,
                CURRENCY_CODE
            })
            .where({ NODE_KEY });

        return 'Product updated successfully';

    });

    // ==================================================
    // DELETE EMPLOYEE
    // ==================================================

    this.on('deleteEmployee', async (req) => {

        const { ID } = req.data;

        await DELETE.from(EmployeeSrv)
            .where({ ID });

        return 'Employee deleted successfully';

    });

    // ==================================================
    // HIGHEST SALARIED EMPLOYEES
    // ==================================================

    this.on('getHighestSalariedEmployees', async () => {

        return await SELECT
            .from(EmployeeSrv)
            .orderBy('salaryAmount desc')
            .limit(10);

    });

    // ==================================================
    // HIGHEST PRICE PRODUCTS
    // ==================================================

    this.on('getHighestPriceProducts', async () => {

        return await SELECT
            .from(ProductSrv)
            .orderBy('PRICE desc')
            .limit(10);

    });

    // ==================================================
    // TOP 20 PRODUCTS
    // ==================================================

    // ==================================================
    // TOP 20 PRODUCTS
    // ==================================================

    this.on('getTop20Products', async () => {

        return await SELECT
            .from(ProductSrv)
            .orderBy('PRICE desc')
            .limit(20);

    });

    // ==================================================
    // PRODUCT PRICE +10%
    // ==================================================

    this.on('increasePriceBy10Percent', async (req) => {

        const key = req.params[0].NODE_KEY;

        const product = await SELECT.one
            .from(ProductSrv)
            .where({
                NODE_KEY: key
            });

        if (!product) {

            return req.reject(
                404,
                'Product not found'
            );

        }

        const oldPrice = Number(product.PRICE);

        const newPrice = Number(
            (oldPrice * 1.10).toFixed(2)
        );

        await UPDATE(ProductSrv)
            .set({
                PRICE: newPrice
            })
            .where({
                NODE_KEY: key
            });

        return `Price increased from ${oldPrice} to ${newPrice}`;

    });

    // ==================================================
    // EMPLOYEE SALARY +10%
    // ==================================================

    this.on('increaseSalaryBy10Percent', async (req) => {

        const key = req.params[0].ID;

        const employee = await SELECT.one
            .from(EmployeeSrv)
            .where({
                ID: key
            });

        if (!employee) {

            return req.reject(
                404,
                'Employee not found'
            );

        }

        const oldSalary = Number(
            employee.salaryAmount
        );

        const newSalary = Number(
            (oldSalary * 1.10).toFixed(2)
        );

        await UPDATE(EmployeeSrv)
            .set({
                salaryAmount: newSalary
            })
            .where({
                ID: key
            });

        return `Salary increased from ${oldSalary} to ${newSalary}`;

    });

    // ==================================================
    // GET UTILITIES
    // ==================================================

    this.on('getUtilities', async () => {

        let uuid = randomUUID();

        let inputURI = "%E0%A4%A4";
        let uri;

        let isFileExists = false;
        let dirExists = false;

        if (existsSync('srv/request.http')) {
            isFileExists = true;
        }

        if (existsSync('app')) {
            dirExists = true;
        }

        try {

            uri = decodeURI(inputURI);

            if (!existsSync('srv/lib')) {
                mkdirSync('srv/lib');
            }

        } catch {

            uri = inputURI;

        }

        const packageInfo = readFileSync(
            'package.json',
            'utf8'
        );

        return {
            uuid,
            uri,
            isFileExists,
            dirExists,
            packageInfo: JSON.parse(packageInfo)
        };

    });

});