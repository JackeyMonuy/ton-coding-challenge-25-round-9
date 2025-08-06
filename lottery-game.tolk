const MY_WORKCHAIN = BASECHAIN;
const OP_JOIN = stringCrc32("join"); // 9b31d2ef
const OP_DRAW = stringCrc32("draw"); // a883b102

var participants: int = 0;
var lastWinner: int = -1;

fun joinLottery() {
    participants += 1;
}

fun drawWinner() {
    assert(participants > 0) throw 1003;
    lastWinner = now() % participants;
}

fun routeInternal(`ctx::sender`: slice, `ctx::value`: int, `ctx::fwd_fee`: int, `ctx::body`: slice) {
    var (op: int, _) = `ctx::body`.loadOpAndQueryId();

    if (op == OP_JOIN) {
        joinLottery();
        return;
    }

    if (op == OP_DRAW) {
        drawWinner();
        return;
    }

    throw 0xffff;
}

fun main(`ctx::value`: int, inMsgFull: cell, `ctx::body`: slice) {
    var s = inMsgFull.beginParse();
    var flags = s.loadMsgFlags();
    if (isBounced(flags)) { return; }

    var (`ctx::sender`: slice, `ctx::fwd_fee`: int) = s.retrieveCtx(MY_WORKCHAIN);
    routeInternal(`ctx::sender`, `ctx::value`, `ctx::fwd_fee`, `ctx::body`);
}
