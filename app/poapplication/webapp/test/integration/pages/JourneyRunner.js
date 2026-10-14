sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"poapplication/poapplication/test/integration/pages/PurchaseOrderSrvList.gen",
	"poapplication/poapplication/test/integration/pages/PurchaseOrderSrvObjectPage.gen"
], function (JourneyRunner, PurchaseOrderSrvListGenerated, PurchaseOrderSrvObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('poapplication/poapplication') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrderSrvListGenerated: PurchaseOrderSrvListGenerated,
			onThePurchaseOrderSrvObjectPageGenerated: PurchaseOrderSrvObjectPageGenerated
        },
        async: true
    });

    return runner;
});

