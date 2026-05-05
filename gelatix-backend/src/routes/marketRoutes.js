const router  = require("express").Router();
const ctrl    = require("../controllers/marketController");
const auth    = require("../middleware/authMiddleware");
const role    = require("../middleware/roleMiddleware");

const anyRole = role(["user", "organizer", "admin"]);

router.get("/",                       ctrl.getResaleListings);        // public
router.post("/list",           auth, anyRole, ctrl.listTicketForSale); // jual tiket
router.get("/my-listings",     auth, anyRole, ctrl.getMyListings);     // tiket saya yang dijual
router.post("/:listingId/buy", auth, anyRole, ctrl.buyResaleTicket);   // beli tiket resale
router.delete("/:listingId/cancel", auth, anyRole, ctrl.cancelListing);// batalkan listing

module.exports = router;