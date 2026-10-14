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

    const { PurchaseOrders } = cds.entities('poapplication.db.transaction');

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

        return await SELECT
            .from(EmployeeSrv)
            .where({ ID: employee.ID });

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
    // PURCHASE ORDER DISCOUNT -10%
    // ==================================================

    this.on('discount', PurchaseOrderSrv, async (req) => {

        const key = req.params[0].NODE_KEY;

        const order = await SELECT.one
            .from(PurchaseOrderSrv)
            .where({
                NODE_KEY: key
            });

        if (!order) {

            return req.reject(
                404,
                'Purchase order not found'
            );

        }

        const discounted = (amount) => Number(
            (Number(amount) * 0.90).toFixed(2)
        );

        await UPDATE(PurchaseOrders)
            .set({
                GROSS_AMOUNT: discounted(order.GROSS_AMOUNT),
                NET_AMOUNT: discounted(order.NET_AMOUNT),
                TAX_AMOUNT: discounted(order.TAX_AMOUNT)
            })
            .where({
                NODE_KEY: key
            });

        return await SELECT.one
            .from(PurchaseOrderSrv)
            .where({
                NODE_KEY: key
            });

    });

    // ==================================================
    // CREATE ADDRESS (class version)
    // ==================================================

    this.on('createAddressSrv', async (req) => {

        const address = { ...req.data, NODE_KEY: req.data.NODE_KEY || randomUUID() };

        await INSERT.into(AddressSrv)
            .entries(address);

        return await SELECT
            .from(AddressSrv)
            .where({ NODE_KEY: address.NODE_KEY });

    });

    // ==================================================
    // CREATE PRODUCT
    // ==================================================

    this.on('createProduct', async (req) => {

        const product = { ...req.data, NODE_KEY: req.data.NODE_KEY || randomUUID() };

        await INSERT.into(ProductSrv)
            .entries(product);

        return await SELECT
            .from(ProductSrv)
            .where({ NODE_KEY: product.NODE_KEY });

    });

    // ==================================================
    // UPDATE PRODUCT PRICE
    // ==================================================

    this.on('updateProductPrice', async (req) => {

        const { NODE_KEY, PRICE } = req.data;

        await UPDATE(ProductSrv)
            .set({ PRICE })
            .where({ NODE_KEY });

        return 'Product price updated successfully';

    });

    // ==================================================
    // HIGHEST PRICED PRODUCT (class version)
    // ==================================================

    this.on('getHeighestPricedProduct', async () => {

        return await SELECT
            .from(ProductSrv)
            .orderBy('PRICE desc')
            .limit(1);

    });

    // ==================================================
    // PRODUCT PRICE +10% (class version) / TOP 20
    // ==================================================

    this.on('increasePrice', ProductSrv, async (req) => {

        const key = req.params[0].NODE_KEY;

        await UPDATE(ProductSrv)
            .set({ PRICE: { '*=': 1.10 } })
            .where({ NODE_KEY: key });

        return await SELECT
            .from(ProductSrv)
            .where({ NODE_KEY: key });

    });

    this.on('top_20_product', ProductSrv, async () => {

        return await SELECT
            .from(ProductSrv)
            .orderBy('PRICE desc')
            .limit(20);

    });

    // ==================================================
    // EMPLOYEE SALARY +15% (class version) / TOP 20
    // ==================================================

    this.on('increaseSalary', EmployeeSrv, async (req) => {

        const key = req.params[0].ID;

        await UPDATE(EmployeeSrv)
            .set({ salaryAmount: { '*=': 1.15 } })
            .where({ ID: key });

        return await SELECT
            .from(EmployeeSrv)
            .where({ ID: key });

    });

    this.on('Top20PaidEmployee', EmployeeSrv, async () => {

        return await SELECT
            .from(EmployeeSrv)
            .orderBy('salaryAmount desc')
            .limit(20);

    });

    // ==================================================
    // PURCHASE ORDER DISCOUNT -1000 (class version)
    // ==================================================

    this.on('discountPrice', PurchaseOrderSrv, async (req) => {

        const key = req.params[0].NODE_KEY;

        const order = await SELECT.one
            .from(PurchaseOrders)
            .where({ NODE_KEY: key });

        if (!order) {
            return req.reject(404, 'Purchase order not found');
        }

        if (Number(order.GROSS_AMOUNT) < 1000) {
            return req.reject(400, 'Gross amount is below 1000, discount not possible');
        }

        // PurchaseOrderSrv is a join view, so update the underlying table
        await UPDATE(PurchaseOrders)
            .set({
                GROSS_AMOUNT: { '-=': 1000 },
                NET_AMOUNT: { '-=': 800 },
                TAX_AMOUNT: { '-=': 200 }
            })
            .where({ NODE_KEY: key });

        return await SELECT
            .from(PurchaseOrderSrv)
            .where({ NODE_KEY: key });

    });

    // ==================================================
    // LARGEST ORDERS (top 5 by gross amount)
    // ==================================================

    this.on('largestOrder', PurchaseOrderSrv, async () => {

        return await SELECT
            .from(PurchaseOrderSrv)
            .orderBy('GROSS_AMOUNT desc')
            .limit(5);

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