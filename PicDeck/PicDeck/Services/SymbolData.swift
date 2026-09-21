// 由系統的 SF Symbols 目錄產生（CoreGlyphs），排除授權受限與各語系變體。
// 每行：分類|符號名稱。執行時再用 UIImage(systemName:) 濾掉目前系統沒有的。
enum SymbolData {
    static let raw = """
indices|0.circle|圓形
indices|0.circle.fill|圓形
indices|0.square|方形
indices|0.square.fill|方形
indices|00.circle|圓形
indices|00.circle.fill|圓形
indices|00.square|方形
indices|00.square.fill|方形
indices|01.circle|圓形
indices|01.circle.fill|圓形
indices|01.square|方形
indices|01.square.fill|方形
indices|02.circle|圓形
indices|02.circle.fill|圓形
indices|02.square|方形
indices|02.square.fill|方形
indices|03.circle|圓形
indices|03.circle.fill|圓形
indices|03.square|方形
indices|03.square.fill|方形
indices|04.circle|圓形
indices|04.circle.fill|圓形
indices|04.square|方形
indices|04.square.fill|方形
indices|05.circle|圓形
indices|05.circle.fill|圓形
indices|05.square|方形
indices|05.square.fill|方形
indices|06.circle|圓形
indices|06.circle.fill|圓形
indices|06.square|方形
indices|06.square.fill|方形
indices|07.circle|圓形
indices|07.circle.fill|圓形
indices|07.square|方形
indices|07.square.fill|方形
indices|08.circle|圓形
indices|08.circle.fill|圓形
indices|08.square|方形
indices|08.square.fill|方形
indices|09.circle|圓形
indices|09.circle.fill|圓形
indices|09.square|方形
indices|09.square.fill|方形
indices|1.circle|圓形
indices|1.circle.fill|圓形
indices|1.square|方形
indices|1.square.fill|方形
indices|10.circle|圓形
indices|10.circle.fill|圓形
indices|10.square|方形
indices|10.square.fill|方形
indices|11.circle|圓形
indices|11.circle.fill|圓形
indices|11.square|方形
indices|11.square.fill|方形
indices|12.circle|圓形
indices|12.circle.fill|圓形
indices|12.square|方形
indices|12.square.fill|方形
indices|13.circle|圓形
indices|13.circle.fill|圓形
indices|13.square|方形
indices|13.square.fill|方形
indices|14.circle|圓形
indices|14.circle.fill|圓形
indices|14.square|方形
indices|14.square.fill|方形
indices|15.circle|圓形
indices|15.circle.fill|圓形
indices|15.square|方形
indices|15.square.fill|方形
indices|16.circle|圓形
indices|16.circle.fill|圓形
indices|16.square|方形
indices|16.square.fill|方形
indices|17.circle|圓形
indices|17.circle.fill|圓形
indices|17.square|方形
indices|17.square.fill|方形
indices|18.circle|圓形
indices|18.circle.fill|圓形
indices|18.square|方形
indices|18.square.fill|方形
indices|19.circle|圓形
indices|19.circle.fill|圓形
indices|19.square|方形
indices|19.square.fill|方形
indices|2.circle|圓形
indices|2.circle.fill|圓形
indices|2.square|方形
indices|2.square.fill|方形
indices|20.circle|圓形
indices|20.circle.fill|圓形
indices|20.square|方形
indices|20.square.fill|方形
indices|21.circle|圓形
indices|21.circle.fill|圓形
indices|21.square|方形
indices|21.square.fill|方形
indices|22.circle|圓形
indices|22.circle.fill|圓形
indices|22.square|方形
indices|22.square.fill|方形
indices|23.circle|圓形
indices|23.circle.fill|圓形
indices|23.square|方形
indices|23.square.fill|方形
indices|24.circle|圓形
indices|24.circle.fill|圓形
indices|24.square|方形
indices|24.square.fill|方形
indices|25.circle|圓形
indices|25.circle.fill|圓形
indices|25.square|方形
indices|25.square.fill|方形
indices|26.circle|圓形
indices|26.circle.fill|圓形
indices|26.square|方形
indices|26.square.fill|方形
indices|27.circle|圓形
indices|27.circle.fill|圓形
indices|27.square|方形
indices|27.square.fill|方形
indices|28.circle|圓形
indices|28.circle.fill|圓形
indices|28.square|方形
indices|28.square.fill|方形
indices|29.circle|圓形
indices|29.circle.fill|圓形
indices|29.square|方形
indices|29.square.fill|方形
indices|3.circle|圓形
indices|3.circle.fill|圓形
indices|3.square|方形
indices|3.square.fill|方形
indices|30.circle|圓形
indices|30.circle.fill|圓形
indices|30.square|方形
indices|30.square.fill|方形
indices|31.circle|圓形
indices|31.circle.fill|圓形
indices|31.square|方形
indices|31.square.fill|方形
indices|32.circle|圓形
indices|32.circle.fill|圓形
indices|32.square|方形
indices|32.square.fill|方形
indices|33.circle|圓形
indices|33.circle.fill|圓形
indices|33.square|方形
indices|33.square.fill|方形
indices|34.circle|圓形
indices|34.circle.fill|圓形
indices|34.square|方形
indices|34.square.fill|方形
indices|35.circle|圓形
indices|35.circle.fill|圓形
indices|35.square|方形
indices|35.square.fill|方形
indices|36.circle|圓形
indices|36.circle.fill|圓形
indices|36.square|方形
indices|36.square.fill|方形
indices|37.circle|圓形
indices|37.circle.fill|圓形
indices|37.square|方形
indices|37.square.fill|方形
indices|38.circle|圓形
indices|38.circle.fill|圓形
indices|38.square|方形
indices|38.square.fill|方形
indices|39.circle|圓形
indices|39.circle.fill|圓形
indices|39.square|方形
indices|39.square.fill|方形
indices|4.alt.circle|圓形
indices|4.alt.circle.fill|圓形
indices|4.alt.square|方形
indices|4.alt.square.fill|方形
indices|4.circle|圓形
indices|4.circle.fill|圓形
indices|4.square|方形
indices|4.square.fill|方形
indices|40.circle|圓形
indices|40.circle.fill|圓形
indices|40.square|方形
indices|40.square.fill|方形
indices|41.circle|圓形
indices|41.circle.fill|圓形
indices|41.square|方形
indices|41.square.fill|方形
indices|42.circle|圓形
indices|42.circle.fill|圓形
indices|42.square|方形
indices|42.square.fill|方形
indices|43.circle|圓形
indices|43.circle.fill|圓形
indices|43.square|方形
indices|43.square.fill|方形
indices|44.circle|圓形
indices|44.circle.fill|圓形
indices|44.square|方形
indices|44.square.fill|方形
indices|45.circle|圓形
indices|45.circle.fill|圓形
indices|45.square|方形
indices|45.square.fill|方形
indices|46.circle|圓形
indices|46.circle.fill|圓形
indices|46.square|方形
indices|46.square.fill|方形
indices|47.circle|圓形
indices|47.circle.fill|圓形
indices|47.square|方形
indices|47.square.fill|方形
indices|48.circle|圓形
indices|48.circle.fill|圓形
indices|48.square|方形
indices|48.square.fill|方形
indices|49.circle|圓形
indices|49.circle.fill|圓形
indices|49.square|方形
indices|49.square.fill|方形
indices|5.circle|圓形
indices|5.circle.fill|圓形
indices|5.square|方形
indices|5.square.fill|方形
indices|50.circle|圓形
indices|50.circle.fill|圓形
indices|50.square|方形
indices|50.square.fill|方形
indices|6.alt.circle|圓形
indices|6.alt.circle.fill|圓形
indices|6.alt.square|方形
indices|6.alt.square.fill|方形
indices|6.circle|圓形
indices|6.circle.fill|圓形
indices|6.square|方形
indices|6.square.fill|方形
indices|7.circle|圓形
indices|7.circle.fill|圓形
indices|7.square|方形
indices|7.square.fill|方形
indices|8.circle|圓形
indices|8.circle.fill|圓形
indices|8.square|方形
indices|8.square.fill|方形
indices|9.alt.circle|圓形
indices|9.alt.circle.fill|圓形
indices|9.alt.square|方形
indices|9.alt.square.fill|方形
indices|9.circle|圓形
indices|9.circle.fill|圓形
indices|9.square|方形
indices|9.square.fill|方形
indices|a.square|方形
indices|a.square.fill|方形
indices|b.square|方形
indices|b.square.fill|方形
indices|c.square|方形
indices|c.square.fill|方形
indices|d.circle|圓形
indices|d.circle.fill|圓形
indices|d.square|方形
indices|d.square.fill|方形
indices|e.circle|圓形
indices|e.circle.fill|圓形
indices|e.square|方形
indices|e.square.fill|方形
indices|exclamationmark.circle|驚嘆號 警告 圓形
indices|exclamationmark.circle.fill|驚嘆號 警告 圓形
indices|exclamationmark.square|驚嘆號 警告 方形
indices|exclamationmark.square.fill|驚嘆號 警告 方形
indices|f.circle|圓形
indices|f.circle.fill|圓形
indices|f.square|方形
indices|f.square.fill|方形
indices|g.circle|圓形
indices|g.circle.fill|圓形
indices|g.square|方形
indices|g.square.fill|方形
indices|h.circle|圓形
indices|h.circle.fill|圓形
indices|h.square|方形
indices|h.square.fill|方形
indices|i.circle|圓形
indices|i.circle.fill|圓形
indices|i.square|方形
indices|i.square.fill|方形
indices|j.circle|圓形
indices|j.circle.fill|圓形
indices|j.square|方形
indices|j.square.fill|方形
indices|k.circle|圓形
indices|k.circle.fill|圓形
indices|k.square|方形
indices|k.square.fill|方形
indices|l.square|方形
indices|l.square.fill|方形
indices|m.circle|圓形
indices|m.circle.fill|圓形
indices|m.square|方形
indices|m.square.fill|方形
indices|n.circle|圓形
indices|n.circle.fill|圓形
indices|n.square|方形
indices|n.square.fill|方形
indices|o.circle|圓形
indices|o.circle.fill|圓形
indices|o.square|方形
indices|o.square.fill|方形
indices|p.circle|圓形
indices|p.circle.fill|圓形
indices|p.square|方形
indices|p.square.fill|方形
indices|q.circle|圓形
indices|q.circle.fill|圓形
indices|q.square|方形
indices|q.square.fill|方形
indices|questionmark.circle|問號 圓形
indices|questionmark.circle.fill|問號 圓形
indices|questionmark.square|問號 方形
indices|questionmark.square.fill|問號 方形
indices|r.square|方形
indices|r.square.fill|方形
indices|s.circle|圓形
indices|s.circle.fill|圓形
indices|s.square|方形
indices|s.square.fill|方形
indices|t.circle|圓形
indices|t.circle.fill|圓形
indices|t.square|方形
indices|t.square.fill|方形
indices|u.circle|圓形
indices|u.circle.fill|圓形
indices|u.square|方形
indices|u.square.fill|方形
indices|v.circle|圓形
indices|v.circle.fill|圓形
indices|v.square|方形
indices|v.square.fill|方形
indices|w.circle|圓形
indices|w.circle.fill|圓形
indices|w.square|方形
indices|w.square.fill|方形
indices|x.square|方形
indices|x.square.fill|方形
indices|y.square|方形
indices|y.square.fill|方形
indices|z.square|方形
indices|z.square.fill|方形
automotive|1.brakesignal|
automotive|2.brakesignal|
automotive|2h|
automotive|2h.circle|圓形
automotive|2h.circle.fill|圓形
automotive|4a|
automotive|4a.circle|圓形
automotive|4a.circle.fill|圓形
automotive|4h|
automotive|4h.circle|圓形
automotive|4h.circle.fill|圓形
automotive|4l|
automotive|4l.circle|圓形
automotive|4l.circle.fill|圓形
automotive|abs|
automotive|abs.brakesignal|
automotive|abs.brakesignal.slash|正斜線
automotive|abs.circle|圓形
automotive|abs.circle.fill|圓形
automotive|air.car.side|汽車 車
automotive|air.car.side.fill|汽車 車
automotive|air.conditioner|
automotive|air.conditioner.slash|正斜線
automotive|air.convertible.side|
automotive|air.convertible.side.fill|
automotive|air.pickup.side|
automotive|air.pickup.side.fill|
automotive|air.suv.side|
automotive|air.suv.side.fill|
automotive|arrow.right.filled.filter.arrow.right|箭頭 右
automotive|arrowtriangle.up.arrowtriangle.down.window.left|上 下 窗戶 左
automotive|arrowtriangle.up.arrowtriangle.down.window.right|上 下 窗戶 右
automotive|automatic.brakesignal|
automotive|automatic.headlight.high.beam|
automotive|automatic.headlight.high.beam.fill|
automotive|automatic.headlight.low.beam|
automotive|automatic.headlight.low.beam.fill|
automotive|autostartstop|
automotive|autostartstop.slash|正斜線
automotive|autostartstop.trianglebadge.exclamationmark|驚嘆號 警告
automotive|axle.2|
automotive|axle.2.driveshaft.disengaged|
automotive|axle.2.front.and.rear.engaged|
automotive|axle.2.front.disengaged|
automotive|axle.2.front.engaged|
automotive|axle.2.rear.disengaged|
automotive|axle.2.rear.engaged|
automotive|axle.2.rear.lock|鎖 鎖定
automotive|batteryblock|
automotive|batteryblock.fill|
automotive|batteryblock.slash|正斜線
automotive|batteryblock.slash.fill|正斜線
automotive|batteryblock.stack|
automotive|batteryblock.stack.badge.snowflake|雪花
automotive|batteryblock.stack.badge.snowflake.fill|雪花
automotive|batteryblock.stack.fill|
automotive|batteryblock.stack.trianglebadge.exclamationmark|驚嘆號 警告
automotive|batteryblock.stack.trianglebadge.exclamationmark.fill|驚嘆號 警告
automotive|bolt.batteryblock|閃電
automotive|bolt.batteryblock.fill|閃電
automotive|bolt.brakesignal|閃電
automotive|bolt.car|閃電 汽車 車
automotive|bolt.car.circle|閃電 汽車 車 圓形
automotive|bolt.car.circle.fill|閃電 汽車 車 圓形
automotive|bolt.car.fill|閃電 汽車 車
automotive|book.and.wrench|書 書本 扳手
automotive|book.and.wrench.fill|書 書本 扳手
automotive|brakesignal|
automotive|brakesignal.dashed|
automotive|car|汽車 車
automotive|car.2|汽車 車
automotive|car.2.fill|汽車 車
automotive|car.badge.gearshape|汽車 車 設定 齒輪
automotive|car.badge.gearshape.fill|汽車 車 設定 齒輪
automotive|car.circle|汽車 車 圓形
automotive|car.circle.fill|汽車 車 圓形
automotive|car.fill|汽車 車
automotive|car.front.waves.down|汽車 車 波浪 下
automotive|car.front.waves.down.fill|汽車 車 波浪 下
automotive|car.front.waves.left.and.right.and.up|汽車 車 波浪 左 右 上
automotive|car.front.waves.left.and.right.and.up.fill|汽車 車 波浪 左 右 上
automotive|car.front.waves.up|汽車 車 波浪 上
automotive|car.front.waves.up.fill|汽車 車 波浪 上
automotive|car.rear|汽車 車
automotive|car.rear.and.collision.road.lane|汽車 車 碰撞
automotive|car.rear.and.collision.road.lane.slash|汽車 車 碰撞 正斜線
automotive|car.rear.and.tire.marks|汽車 車
automotive|car.rear.and.tire.marks.off|汽車 車
automotive|car.rear.and.tire.marks.slash|汽車 車 正斜線
automotive|car.rear.fill|汽車 車
automotive|car.rear.hazardsign|汽車 車
automotive|car.rear.hazardsign.fill|汽車 車
automotive|car.rear.road.lane|汽車 車
automotive|car.rear.road.lane.dashed|汽車 車
automotive|car.rear.road.lane.dashed.arrowtriangle.2.outward|汽車 車
automotive|car.rear.road.lane.distance.1|汽車 車
automotive|car.rear.road.lane.distance.1.and.gauge.open.with.lines.needle.67percent.and.arrowtriangle|汽車 車
automotive|car.rear.road.lane.distance.2|汽車 車
automotive|car.rear.road.lane.distance.2.and.gauge.open.with.lines.needle.67percent.and.arrowtriangle|汽車 車
automotive|car.rear.road.lane.distance.3|汽車 車
automotive|car.rear.road.lane.distance.3.and.gauge.open.with.lines.needle.67percent.and.arrowtriangle|汽車 車
automotive|car.rear.road.lane.distance.4|汽車 車
automotive|car.rear.road.lane.distance.4.and.gauge.open.with.lines.needle.67percent.and.arrowtriangle|汽車 車
automotive|car.rear.road.lane.distance.5|汽車 車
automotive|car.rear.road.lane.distance.5.and.gauge.open.with.lines.needle.67percent.and.arrowtriangle|汽車 車
automotive|car.rear.road.lane.off|汽車 車
automotive|car.rear.road.lane.wave.up|汽車 車 上
automotive|car.rear.tilt.road.lanes.curved.right|汽車 車 右
automotive|car.rear.waves.up|汽車 車 波浪 上
automotive|car.rear.waves.up.fill|汽車 車 波浪 上
automotive|car.side|汽車 車
automotive|car.side.air.circulate|汽車 車
automotive|car.side.air.circulate.fill|汽車 車
automotive|car.side.air.fresh|汽車 車
automotive|car.side.air.fresh.fill|汽車 車
automotive|car.side.and.exclamationmark|汽車 車 驚嘆號 警告
automotive|car.side.and.exclamationmark.fill|汽車 車 驚嘆號 警告
automotive|car.side.arrow.left.and.right|汽車 車 箭頭 左 右
automotive|car.side.arrow.left.and.right.fill|汽車 車 箭頭 左 右
automotive|car.side.arrowtriangle.down|汽車 車 下
automotive|car.side.arrowtriangle.down.fill|汽車 車 下
automotive|car.side.arrowtriangle.up|汽車 車 上
automotive|car.side.arrowtriangle.up.arrowtriangle.down|汽車 車 上 下
automotive|car.side.arrowtriangle.up.arrowtriangle.down.fill|汽車 車 上 下
automotive|car.side.arrowtriangle.up.fill|汽車 車 上
automotive|car.side.fill|汽車 車
automotive|car.side.front.open|汽車 車
automotive|car.side.front.open.crop|汽車 車
automotive|car.side.front.open.crop.fill|汽車 車
automotive|car.side.front.open.fill|汽車 車
automotive|car.side.hill.descent.control|汽車 車
automotive|car.side.hill.descent.control.fill|汽車 車
automotive|car.side.hill.down|汽車 車 下
automotive|car.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle|汽車 車 下
automotive|car.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle.fill|汽車 車 下
automotive|car.side.hill.down.fill|汽車 車 下
automotive|car.side.hill.up|汽車 車 上
automotive|car.side.hill.up.fill|汽車 車 上
automotive|car.side.lock|汽車 車 鎖 鎖定
automotive|car.side.lock.fill|汽車 車 鎖 鎖定
automotive|car.side.lock.open|汽車 車 鎖 鎖定 解鎖
automotive|car.side.lock.open.fill|汽車 車 鎖 鎖定 解鎖
automotive|car.side.rear.and.collision.and.car.side.front|汽車 車 碰撞
automotive|car.side.rear.and.collision.and.car.side.front.and.arrow.forward|汽車 車 碰撞 箭頭 快轉
automotive|car.side.rear.and.collision.and.car.side.front.and.steeringwheel|汽車 車 碰撞
automotive|car.side.rear.and.collision.and.car.side.front.slash|汽車 車 碰撞 正斜線
automotive|car.side.rear.and.exclamationmark.and.car.side.front|汽車 車 驚嘆號 警告
automotive|car.side.rear.and.exclamationmark.and.car.side.front.off|汽車 車 驚嘆號 警告
automotive|car.side.rear.and.wave.3.and.car.side.front|汽車 車
automotive|car.side.rear.crop.trunk.partition|汽車 車
automotive|car.side.rear.crop.trunk.partition.fill|汽車 車
automotive|car.side.rear.open|汽車 車
automotive|car.side.rear.open.crop|汽車 車
automotive|car.side.rear.open.crop.fill|汽車 車
automotive|car.side.rear.open.fill|汽車 車
automotive|car.side.rear.tow.hitch|汽車 車
automotive|car.side.rear.tow.hitch.fill|汽車 車
automotive|car.side.roof.cargo.carrier|汽車 車
automotive|car.side.roof.cargo.carrier.fill|汽車 車
automotive|car.side.roof.cargo.carrier.slash|汽車 車 正斜線
automotive|car.side.roof.cargo.carrier.slash.fill|汽車 車 正斜線
automotive|car.top.arrowtriangle.front.left|汽車 車 左
automotive|car.top.arrowtriangle.front.left.fill|汽車 車 左
automotive|car.top.arrowtriangle.front.right|汽車 車 右
automotive|car.top.arrowtriangle.front.right.fill|汽車 車 右
automotive|car.top.arrowtriangle.rear.left|汽車 車 左
automotive|car.top.arrowtriangle.rear.left.fill|汽車 車 左
automotive|car.top.arrowtriangle.rear.right|汽車 車 右
automotive|car.top.arrowtriangle.rear.right.fill|汽車 車 右
automotive|car.top.door.front.left.and.front.right.and.rear.left.and.rear.right.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.and.rear.left.and.rear.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.and.rear.left.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.and.rear.left.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.and.rear.right.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.and.rear.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.front.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.and.rear.left.and.rear.right.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.rear.left.and.rear.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.and.rear.left.open|汽車 車 門 左
automotive|car.top.door.front.left.and.rear.left.open.fill|汽車 車 門 左
automotive|car.top.door.front.left.and.rear.right.open|汽車 車 門 左 右
automotive|car.top.door.front.left.and.rear.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.front.left.open|汽車 車 門 左
automotive|car.top.door.front.left.open.fill|汽車 車 門 左
automotive|car.top.door.front.right.and.rear.left.and.rear.right.open|汽車 車 門 右 左
automotive|car.top.door.front.right.and.rear.left.and.rear.right.open.fill|汽車 車 門 右 左
automotive|car.top.door.front.right.and.rear.left.open|汽車 車 門 右 左
automotive|car.top.door.front.right.and.rear.left.open.fill|汽車 車 門 右 左
automotive|car.top.door.front.right.and.rear.right.open|汽車 車 門 右
automotive|car.top.door.front.right.and.rear.right.open.fill|汽車 車 門 右
automotive|car.top.door.front.right.open|汽車 車 門 右
automotive|car.top.door.front.right.open.fill|汽車 車 門 右
automotive|car.top.door.rear.left.and.rear.right.open|汽車 車 門 左 右
automotive|car.top.door.rear.left.and.rear.right.open.fill|汽車 車 門 左 右
automotive|car.top.door.rear.left.open|汽車 車 門 左
automotive|car.top.door.rear.left.open.fill|汽車 車 門 左
automotive|car.top.door.rear.right.open|汽車 車 門 右
automotive|car.top.door.rear.right.open.fill|汽車 車 門 右
automotive|car.top.door.sliding.left.open|汽車 車 門 左
automotive|car.top.door.sliding.left.open.fill|汽車 車 門 左
automotive|car.top.door.sliding.right.open|汽車 車 門 右
automotive|car.top.door.sliding.right.open.fill|汽車 車 門 右
automotive|car.top.front.radiowaves.front.left.and.front.and.front.right|汽車 車 左 右
automotive|car.top.front.radiowaves.front.left.and.front.and.front.right.fill|汽車 車 左 右
automotive|car.top.lane.dashed.arrowtriangle.inward|汽車 車
automotive|car.top.lane.dashed.arrowtriangle.inward.fill|汽車 車
automotive|car.top.lane.dashed.badge.steeringwheel|汽車 車
automotive|car.top.lane.dashed.badge.steeringwheel.fill|汽車 車
automotive|car.top.lane.dashed.departure.left|汽車 車 左
automotive|car.top.lane.dashed.departure.left.fill|汽車 車 左
automotive|car.top.lane.dashed.departure.left.slash|汽車 車 左 正斜線
automotive|car.top.lane.dashed.departure.left.slash.fill|汽車 車 左 正斜線
automotive|car.top.lane.dashed.departure.right|汽車 車 右
automotive|car.top.lane.dashed.departure.right.fill|汽車 車 右
automotive|car.top.lane.dashed.departure.right.slash|汽車 車 右 正斜線
automotive|car.top.lane.dashed.departure.right.slash.fill|汽車 車 右 正斜線
automotive|car.top.radiowaves.2.front.left.front.front.right|汽車 車 左 右
automotive|car.top.radiowaves.2.front.left.front.front.right.fill|汽車 車 左 右
automotive|car.top.radiowaves.2.rear.left.rear.rear.right|汽車 車 左 右
automotive|car.top.radiowaves.2.rear.left.rear.rear.right.fill|汽車 車 左 右
automotive|car.top.radiowaves.front|汽車 車
automotive|car.top.radiowaves.front.fill|汽車 車
automotive|car.top.radiowaves.rear|汽車 車
automotive|car.top.radiowaves.rear.fill|汽車 車
automotive|car.top.radiowaves.rear.left|汽車 車 左
automotive|car.top.radiowaves.rear.left.and.rear.right|汽車 車 左 右
automotive|car.top.radiowaves.rear.left.and.rear.right.fill|汽車 車 左 右
automotive|car.top.radiowaves.rear.left.car.top.front|汽車 車 左
automotive|car.top.radiowaves.rear.left.car.top.front.fill|汽車 車 左
automotive|car.top.radiowaves.rear.left.fill|汽車 車 左
automotive|car.top.radiowaves.rear.right|汽車 車 右
automotive|car.top.radiowaves.rear.right.badge.exclamationmark|汽車 車 右 驚嘆號 警告
automotive|car.top.radiowaves.rear.right.badge.exclamationmark.fill|汽車 車 右 驚嘆號 警告
automotive|car.top.radiowaves.rear.right.badge.xmark|汽車 車 右 叉 關閉
automotive|car.top.radiowaves.rear.right.badge.xmark.fill|汽車 車 右 叉 關閉
automotive|car.top.radiowaves.rear.right.car.top.front|汽車 車 右
automotive|car.top.radiowaves.rear.right.car.top.front.fill|汽車 車 右
automotive|car.top.radiowaves.rear.right.fill|汽車 車 右
automotive|car.top.rear.radiowaves.rear.left.and.rear.and.rear.right|汽車 車 左 右
automotive|car.top.rear.radiowaves.rear.left.and.rear.and.rear.right.fill|汽車 車 左 右
automotive|car.top.video.rear.left|汽車 車 影片 錄影 左
automotive|car.top.video.rear.left.fill|汽車 車 影片 錄影 左
automotive|car.top.video.rear.right|汽車 車 影片 錄影 右
automotive|car.top.video.rear.right.fill|汽車 車 影片 錄影 右
automotive|car.window.left|汽車 車 窗戶 左
automotive|car.window.left.badge.exclamationmark|汽車 車 窗戶 左 驚嘆號 警告
automotive|car.window.left.badge.lock|汽車 車 窗戶 左 鎖 鎖定
automotive|car.window.left.badge.xmark|汽車 車 窗戶 左 叉 關閉
automotive|car.window.left.exclamationmark|汽車 車 窗戶 左 驚嘆號 警告
automotive|car.window.left.xmark|汽車 車 窗戶 左 叉 關閉
automotive|car.window.right|汽車 車 窗戶 右
automotive|car.window.right.badge.exclamationmark|汽車 車 窗戶 右 驚嘆號 警告
automotive|car.window.right.badge.lock|汽車 車 窗戶 右 鎖 鎖定
automotive|car.window.right.badge.xmark|汽車 車 窗戶 右 叉 關閉
automotive|car.window.right.exclamationmark|汽車 車 窗戶 右 驚嘆號 警告
automotive|car.window.right.xmark|汽車 車 窗戶 右 叉 關閉
automotive|carseat.left|左
automotive|carseat.left.1|左
automotive|carseat.left.1.fill|左
automotive|carseat.left.2|左
automotive|carseat.left.2.fill|左
automotive|carseat.left.3|左
automotive|carseat.left.3.fill|左
automotive|carseat.left.and.heat.waves|左 波浪
automotive|carseat.left.and.heat.waves.fill|左 波浪
automotive|carseat.left.backrest.up.and.down|左 上 下
automotive|carseat.left.backrest.up.and.down.fill|左 上 下
automotive|carseat.left.fan|左
automotive|carseat.left.fan.fill|左
automotive|carseat.left.fill|左
automotive|carseat.left.forward.and.backward|左 快轉 倒轉
automotive|carseat.left.forward.and.backward.fill|左 快轉 倒轉
automotive|carseat.left.massage|左
automotive|carseat.left.massage.fill|左
automotive|carseat.left.up.and.down|左 上 下
automotive|carseat.left.up.and.down.fill|左 上 下
automotive|carseat.right|右
automotive|carseat.right.1|右
automotive|carseat.right.1.fill|右
automotive|carseat.right.2|右
automotive|carseat.right.2.fill|右
automotive|carseat.right.3|右
automotive|carseat.right.3.fill|右
automotive|carseat.right.and.heat.waves|右 波浪
automotive|carseat.right.and.heat.waves.fill|右 波浪
automotive|carseat.right.backrest.up.and.down|右 上 下
automotive|carseat.right.backrest.up.and.down.fill|右 上 下
automotive|carseat.right.fan|右
automotive|carseat.right.fan.fill|右
automotive|carseat.right.fill|右
automotive|carseat.right.forward.and.backward|右 快轉 倒轉
automotive|carseat.right.forward.and.backward.fill|右 快轉 倒轉
automotive|carseat.right.massage|右
automotive|carseat.right.massage.fill|右
automotive|carseat.right.up.and.down|右 上 下
automotive|carseat.right.up.and.down.fill|右 上 下
automotive|convertible.side|
automotive|convertible.side.air.circulate|
automotive|convertible.side.air.circulate.fill|
automotive|convertible.side.air.fresh|
automotive|convertible.side.air.fresh.fill|
automotive|convertible.side.and.exclamationmark|驚嘆號 警告
automotive|convertible.side.and.exclamationmark.fill|驚嘆號 警告
automotive|convertible.side.arrow.left.and.right|箭頭 左 右
automotive|convertible.side.arrow.left.and.right.fill|箭頭 左 右
automotive|convertible.side.arrow.trianglehead.backward|箭頭 倒轉
automotive|convertible.side.arrow.trianglehead.backward.fill|箭頭 倒轉
automotive|convertible.side.arrow.trianglehead.forward|箭頭 快轉
automotive|convertible.side.arrow.trianglehead.forward.and.backward|箭頭 快轉 倒轉
automotive|convertible.side.arrow.trianglehead.forward.and.backward.fill|箭頭 快轉 倒轉
automotive|convertible.side.arrow.trianglehead.forward.fill|箭頭 快轉
automotive|convertible.side.arrowtriangle.down|下
automotive|convertible.side.arrowtriangle.down.fill|下
automotive|convertible.side.arrowtriangle.up|上
automotive|convertible.side.arrowtriangle.up.arrowtriangle.down|上 下
automotive|convertible.side.arrowtriangle.up.arrowtriangle.down.fill|上 下
automotive|convertible.side.arrowtriangle.up.fill|上
automotive|convertible.side.fill|
automotive|convertible.side.front.open|
automotive|convertible.side.front.open.crop|
automotive|convertible.side.front.open.crop.fill|
automotive|convertible.side.front.open.fill|
automotive|convertible.side.hill.descent.control|
automotive|convertible.side.hill.descent.control.fill|
automotive|convertible.side.hill.down|下
automotive|convertible.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle|下
automotive|convertible.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle.fill|下
automotive|convertible.side.hill.down.fill|下
automotive|convertible.side.hill.up|上
automotive|convertible.side.hill.up.fill|上
automotive|convertible.side.lock|鎖 鎖定
automotive|convertible.side.lock.fill|鎖 鎖定
automotive|convertible.side.lock.open|鎖 鎖定 解鎖
automotive|convertible.side.lock.open.fill|鎖 鎖定 解鎖
automotive|dot.car.top.radiowaves.2.rear.left.rear.rear.right|汽車 車 左 右
automotive|dot.car.top.radiowaves.2.rear.left.rear.rear.right.fill|汽車 車 左 右
automotive|drop.transmission|水滴
automotive|electronic.toll.collection|
automotive|electronic.toll.collection.rectangle|長方形
automotive|electronic.toll.collection.rectangle.fill|長方形
automotive|electronic.toll.collection.rectangle.slash|長方形 正斜線
automotive|electronic.toll.collection.rectangle.slash.fill|長方形 正斜線
automotive|electronic.toll.collection.rectangle.trianglebadge.exclamationmark|長方形 驚嘆號 警告
automotive|electronic.toll.collection.rectangle.trianglebadge.exclamationmark.fill|長方形 驚嘆號 警告
automotive|engine.combustion|
automotive|engine.combustion.badge.exclamationmark|驚嘆號 警告
automotive|engine.combustion.badge.exclamationmark.fill|驚嘆號 警告
automotive|engine.combustion.fill|
automotive|engine.emission.and.drop.2.water.wave.below|水滴 水
automotive|engine.emission.and.exclamationmark|驚嘆號 警告
automotive|engine.emission.and.filter|
automotive|ev.charger|
automotive|ev.charger.arrowtriangle.left|左
automotive|ev.charger.arrowtriangle.left.fill|左
automotive|ev.charger.arrowtriangle.right|右
automotive|ev.charger.arrowtriangle.right.fill|右
automotive|ev.charger.exclamationmark|驚嘆號 警告
automotive|ev.charger.exclamationmark.fill|驚嘆號 警告
automotive|ev.charger.fill|
automotive|ev.charger.slash|正斜線
automotive|ev.charger.slash.fill|正斜線
automotive|ev.plug.ac.gb.t|
automotive|ev.plug.ac.gb.t.fill|
automotive|ev.plug.ac.type.1|
automotive|ev.plug.ac.type.1.fill|
automotive|ev.plug.ac.type.2|
automotive|ev.plug.ac.type.2.fill|
automotive|ev.plug.dc.ccs1|
automotive|ev.plug.dc.ccs1.fill|
automotive|ev.plug.dc.ccs2|
automotive|ev.plug.dc.ccs2.fill|
automotive|ev.plug.dc.chademo|
automotive|ev.plug.dc.chademo.fill|
automotive|ev.plug.dc.gb.t|
automotive|ev.plug.dc.gb.t.fill|
automotive|ev.plug.dc.nacs|
automotive|ev.plug.dc.nacs.fill|
automotive|exclamationmark.brakesignal|驚嘆號 警告
automotive|exclamationmark.tirepressure|驚嘆號 警告
automotive|exclamationmark.transmission|驚嘆號 警告
automotive|exclamationmark.triangle|驚嘆號 警告 三角形
automotive|exclamationmark.triangle.fill|驚嘆號 警告 三角形
automotive|exclamationmark.warninglight|驚嘆號 警告
automotive|exclamationmark.warninglight.fill|驚嘆號 警告
automotive|fan|
automotive|fan.badge.arrow.up.and.down.and.arrow.left.and.right|箭頭 上 下 左 右
automotive|fan.badge.arrow.up.and.down.and.arrow.left.and.right.fill|箭頭 上 下 左 右
automotive|fan.badge.automatic|
automotive|fan.badge.automatic.fill|
automotive|fan.circle|圓形
automotive|fan.circle.fill|圓形
automotive|fan.fill|
automotive|fan.slash|正斜線
automotive|fan.slash.fill|正斜線
automotive|figure.child|人形 孩子 小孩 人 人物
automotive|figure.child.and.lock|人形 孩子 小孩 鎖 鎖定 人 人物
automotive|figure.child.and.lock.fill|人形 孩子 小孩 鎖 鎖定 人 人物
automotive|figure.child.and.lock.open|人形 孩子 小孩 鎖 鎖定 人 人物
automotive|figure.child.and.lock.open.fill|人形 孩子 小孩 鎖 鎖定 人 人物
automotive|figure.child.circle|人形 孩子 小孩 圓形 人 人物
automotive|figure.child.circle.fill|人形 孩子 小孩 圓形 人 人物
automotive|figure.seated.seatbelt|人形 人 人物
automotive|figure.seated.seatbelt.and.airbag.off|人形 人 人物
automotive|figure.seated.seatbelt.and.airbag.on|人形 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1.1|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1.1.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1.2|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1.2.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.1.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2.2|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2.2.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2.3.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.2.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3.2|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3.2.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3.3.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.3.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.2.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3.3.3|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3.3.3.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3.3.fill|人形 左 座位 人 人物
automotive|figure.seated.seatbelt.left.drive.seats.3.fill|人形 左 座位 人 人物
automotive|figure.seated.side.left|人形 左 人 人物
automotive|figure.seated.side.left.air.distribution.indirect|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.lower|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.lower.angled.and.upper.angled|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.middle|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.middle.and.lower|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.middle.and.lower.angled|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper.and.middle.and.lower|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper.angled.and.dottedline.and.lower.angled|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper.angled.and.lower.angled|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper.angled.and.middle|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.air.distribution.upper.angled.and.middle.and.lower.angled|人形 左 箭頭 人 人物
automotive|figure.seated.side.left.airbag.off|人形 左 人 人物
automotive|figure.seated.side.left.airbag.off.2|人形 左 人 人物
automotive|figure.seated.side.left.airbag.on|人形 左 人 人物
automotive|figure.seated.side.left.airbag.on.2|人形 左 人 人物
automotive|figure.seated.side.left.automatic|人形 左 人 人物
automotive|figure.seated.side.left.fan|人形 左 人 人物
automotive|figure.seated.side.left.steeringwheel|人形 左 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves|人形 左 波浪 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.lower|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.middle|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.middle.and.lower|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.upper|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.upper.and.lower|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.upper.and.middle|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.left.windshield.front.and.heat.waves.air.distribution.upper.and.middle.and.lower|人形 左 波浪 箭頭 人 人物
automotive|figure.seated.side.right|人形 右 人 人物
automotive|figure.seated.side.right.air.distribution.indirect|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.lower|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.lower.angled.and.upper.angled|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.middle|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.middle.and.lower|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.middle.and.lower.angled|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper.and.middle.and.lower|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper.angled.and.dottedline.and.lower.angled|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper.angled.and.lower.angled|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper.angled.and.middle|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.air.distribution.upper.angled.and.middle.and.lower.angled|人形 右 箭頭 人 人物
automotive|figure.seated.side.right.airbag.off|人形 右 人 人物
automotive|figure.seated.side.right.airbag.off.2|人形 右 人 人物
automotive|figure.seated.side.right.airbag.on|人形 右 人 人物
automotive|figure.seated.side.right.airbag.on.2|人形 右 人 人物
automotive|figure.seated.side.right.automatic|人形 右 人 人物
automotive|figure.seated.side.right.fan|人形 右 人 人物
automotive|figure.seated.side.right.steeringwheel|人形 右 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves|人形 右 波浪 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.lower|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.middle|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.middle.and.lower|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.upper|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.upper.and.lower|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.upper.and.middle|人形 右 波浪 箭頭 人 人物
automotive|figure.seated.side.right.windshield.front.and.heat.waves.air.distribution.upper.and.middle.and.lower|人形 右 波浪 箭頭 人 人物
automotive|flag.pattern.checkered.lc|旗幟 旗
automotive|fluid.batteryblock|
automotive|fluid.brakesignal|
automotive|fluid.coolant|
automotive|fluid.transmission|
automotive|fuel.filter.water|水
automotive|fuelpump|加油站
automotive|fuelpump.and.filter|加油站
automotive|fuelpump.arrowtriangle.left|加油站 左
automotive|fuelpump.arrowtriangle.left.fill|加油站 左
automotive|fuelpump.arrowtriangle.right|加油站 右
automotive|fuelpump.arrowtriangle.right.fill|加油站 右
automotive|fuelpump.circle|加油站 圓形
automotive|fuelpump.circle.fill|加油站 圓形
automotive|fuelpump.exclamationmark|加油站 驚嘆號 警告
automotive|fuelpump.exclamationmark.fill|加油站 驚嘆號 警告
automotive|fuelpump.fill|加油站
automotive|fuelpump.nozzle.and.drop|加油站 水滴
automotive|fuelpump.slash|加油站 正斜線
automotive|fuelpump.slash.fill|加油站 正斜線
automotive|fuelpump.thermometer|加油站 溫度計 溫度
automotive|fuelpump.thermometer.fill|加油站 溫度計 溫度
automotive|gauge.open.righthalf.dotted.with.needle.and.arrow.trianglehead.backward|箭頭 倒轉
automotive|gauge.open.with.lines.needle.33percent|
automotive|gauge.open.with.lines.needle.33percent.and.arrow.trianglehead.from.0percent.to.50percent|箭頭
automotive|gauge.open.with.lines.needle.33percent.and.arrowtriangle|
automotive|gauge.open.with.lines.needle.67percent.and.arrowtriangle|
automotive|gauge.open.with.lines.needle.67percent.and.arrowtriangle.and.car|汽車 車
automotive|gauge.open.with.lines.needle.84percent.exclamation|警告
automotive|gauge.with.dots.needle.0percent|
automotive|gauge.with.dots.needle.100percent|
automotive|gauge.with.dots.needle.33percent|
automotive|gauge.with.dots.needle.50percent|
automotive|gauge.with.dots.needle.67percent|
automotive|gauge.with.dots.needle.bottom.0percent|
automotive|gauge.with.dots.needle.bottom.100percent|
automotive|gauge.with.dots.needle.bottom.50percent|
automotive|gauge.with.dots.needle.bottom.50percent.badge.minus|減號
automotive|gauge.with.dots.needle.bottom.50percent.badge.plus|加號 新增
automotive|glowplug|
automotive|hand.raised.brakesignal|手
automotive|hand.raised.brakesignal.slash|手 正斜線
automotive|hazardsign|
automotive|hazardsign.fill|
automotive|headlight.daytime|
automotive|headlight.daytime.fill|
automotive|headlight.fog|有霧
automotive|headlight.fog.fill|有霧
automotive|headlight.high.beam|
automotive|headlight.high.beam.fill|
automotive|headlight.low.beam|
automotive|headlight.low.beam.fill|
automotive|headset|
automotive|headset.circle|圓形
automotive|headset.circle.fill|圓形
automotive|heat.element.windshield|
automotive|heat.waves.and.fan|波浪
automotive|hold.brakesignal|
automotive|horn|
automotive|horn.blast|
automotive|horn.blast.fill|
automotive|horn.fill|
automotive|hydrogen|
automotive|hydrogen.circle|圓形
automotive|hydrogen.circle.fill|圓形
automotive|hydrogen.square|方形
automotive|hydrogen.square.fill|方形
automotive|info.square|資訊 方形
automotive|info.square.fill|資訊 方形
automotive|info.windshield|資訊
automotive|key|鑰匙
automotive|key.car.radiowaves.forward|鑰匙 汽車 車 快轉
automotive|key.car.radiowaves.forward.fill|鑰匙 汽車 車 快轉
automotive|key.car.side|鑰匙 汽車 車
automotive|key.car.side.fill|鑰匙 汽車 車
automotive|key.card|鑰匙
automotive|key.card.fill|鑰匙
automotive|key.circle|鑰匙 圓形
automotive|key.circle.fill|鑰匙 圓形
automotive|key.convertible.side|鑰匙
automotive|key.convertible.side.fill|鑰匙
automotive|key.fill|鑰匙
automotive|key.horizontal|鑰匙
automotive|key.horizontal.fill|鑰匙
automotive|key.radiowaves.forward|鑰匙 快轉
automotive|key.radiowaves.forward.fill|鑰匙 快轉
automotive|key.radiowaves.forward.slash|鑰匙 快轉 正斜線
automotive|key.radiowaves.forward.slash.fill|鑰匙 快轉 正斜線
automotive|key.slash|鑰匙 正斜線
automotive|key.slash.fill|鑰匙 正斜線
automotive|key.suv.side|鑰匙
automotive|key.suv.side.fill|鑰匙
automotive|key.truck.pickup.side|鑰匙
automotive|key.truck.pickup.side.fill|鑰匙
automotive|kph|
automotive|kph.circle|圓形
automotive|kph.circle.fill|圓形
automotive|licenseplate|
automotive|licenseplate.fill|
automotive|light.overhead.left|左
automotive|light.overhead.left.fill|左
automotive|light.overhead.right|右
automotive|light.overhead.right.fill|右
automotive|mecca|
automotive|minus.plus.and.fluid.batteryblock|減號 加號 新增
automotive|minus.plus.batteryblock|減號 加號 新增
automotive|minus.plus.batteryblock.exclamationmark|減號 加號 新增 驚嘆號 警告
automotive|minus.plus.batteryblock.exclamationmark.fill|減號 加號 新增 驚嘆號 警告
automotive|minus.plus.batteryblock.fill|減號 加號 新增
automotive|minus.plus.batteryblock.slash|減號 加號 新增 正斜線
automotive|minus.plus.batteryblock.slash.fill|減號 加號 新增 正斜線
automotive|minus.plus.batteryblock.stack|減號 加號 新增
automotive|minus.plus.batteryblock.stack.arrowtriangle.left|減號 加號 新增 左
automotive|minus.plus.batteryblock.stack.arrowtriangle.left.fill|減號 加號 新增 左
automotive|minus.plus.batteryblock.stack.arrowtriangle.right|減號 加號 新增 右
automotive|minus.plus.batteryblock.stack.arrowtriangle.right.and.arrowtriangle.left|減號 加號 新增 右 左
automotive|minus.plus.batteryblock.stack.arrowtriangle.right.and.arrowtriangle.left.fill|減號 加號 新增 右 左
automotive|minus.plus.batteryblock.stack.arrowtriangle.right.fill|減號 加號 新增 右
automotive|minus.plus.batteryblock.stack.exclamationmark|減號 加號 新增 驚嘆號 警告
automotive|minus.plus.batteryblock.stack.exclamationmark.fill|減號 加號 新增 驚嘆號 警告
automotive|minus.plus.batteryblock.stack.fill|減號 加號 新增
automotive|mirror.side.left|鏡子 左
automotive|mirror.side.left.and.arrow.turn.down.right|鏡子 左 箭頭 下 右
automotive|mirror.side.left.and.heat.waves|鏡子 左 波浪
automotive|mirror.side.right|鏡子 右
automotive|mirror.side.right.and.arrow.turn.down.left|鏡子 右 箭頭 下 左
automotive|mirror.side.right.and.heat.waves|鏡子 右 波浪
automotive|moon.road.lanes|月亮
automotive|motor.electric.vehicle|
automotive|mph|
automotive|mph.circle|圓形
automotive|mph.circle.fill|圓形
automotive|oilcan|
automotive|oilcan.and.thermometer|溫度計 溫度
automotive|oilcan.and.thermometer.fill|溫度計 溫度
automotive|oilcan.fill|
automotive|parkinglight|
automotive|parkinglight.fill|
automotive|parkingsign|
automotive|parkingsign.brakesignal|
automotive|parkingsign.brakesignal.slash|正斜線
automotive|parkingsign.circle|圓形
automotive|parkingsign.circle.fill|圓形
automotive|parkingsign.radiowaves.down.right.off|下 右
automotive|parkingsign.radiowaves.left.and.right|左 右
automotive|parkingsign.radiowaves.left.and.right.slash|左 右 正斜線
automotive|parkingsign.radiowaves.right.and.safetycone|右
automotive|parkingsign.square|方形
automotive|parkingsign.square.fill|方形
automotive|parkingsign.steeringwheel|
automotive|powercord|
automotive|powercord.fill|
automotive|powermeter|
automotive|questionmark.key.filled|問號 鑰匙
automotive|retarder.brakesignal|
automotive|retarder.brakesignal.and.exclamationmark|驚嘆號 警告
automotive|retarder.brakesignal.slash|正斜線
automotive|road.lane.arrowtriangle.2.inward|
automotive|road.lane.arrowtriangle.2.outward|
automotive|road.lanes|
automotive|road.lanes.curved.left|左
automotive|road.lanes.curved.right|右
automotive|shoe.arrow.trianglehead.up.and.down|箭頭 上 下
automotive|shoe.arrow.trianglehead.up.and.down.fill|箭頭 上 下
automotive|shoe.arrow.trianglehead.up.right|箭頭 上 右
automotive|shoe.arrow.trianglehead.up.right.circle|箭頭 上 右 圓形
automotive|shoe.arrow.trianglehead.up.right.circle.fill|箭頭 上 右 圓形
automotive|shoe.arrow.trianglehead.up.right.fill|箭頭 上 右
automotive|snowflake|雪花
automotive|snowflake.circle|雪花 圓形
automotive|snowflake.circle.fill|雪花 圓形
automotive|snowflake.road.lane|雪花
automotive|snowflake.road.lane.dashed|雪花
automotive|snowflake.slash|雪花 正斜線
automotive|steeringwheel|
automotive|steeringwheel.and.hands|手
automotive|steeringwheel.and.heat.waves|波浪
automotive|steeringwheel.and.key|鑰匙
automotive|steeringwheel.and.liquid.wave|
automotive|steeringwheel.arrow.trianglehead.counterclockwise.and.clockwise|箭頭
automotive|steeringwheel.arrowtriangle.left|左
automotive|steeringwheel.arrowtriangle.right|右
automotive|steeringwheel.badge.exclamationmark|驚嘆號 警告
automotive|steeringwheel.badge.lock|鎖 鎖定
automotive|steeringwheel.circle|圓形
automotive|steeringwheel.circle.fill|圓形
automotive|steeringwheel.exclamationmark|驚嘆號 警告
automotive|steeringwheel.road.lane|
automotive|steeringwheel.road.lane.dashed|
automotive|steeringwheel.slash|正斜線
automotive|suspension.shock|
automotive|suv.side|
automotive|suv.side.air.circulate|
automotive|suv.side.air.circulate.fill|
automotive|suv.side.air.fresh|
automotive|suv.side.air.fresh.fill|
automotive|suv.side.and.exclamationmark|驚嘆號 警告
automotive|suv.side.and.exclamationmark.fill|驚嘆號 警告
automotive|suv.side.arrow.left.and.right|箭頭 左 右
automotive|suv.side.arrow.left.and.right.fill|箭頭 左 右
automotive|suv.side.arrowtriangle.down|下
automotive|suv.side.arrowtriangle.down.fill|下
automotive|suv.side.arrowtriangle.up|上
automotive|suv.side.arrowtriangle.up.arrowtriangle.down|上 下
automotive|suv.side.arrowtriangle.up.arrowtriangle.down.fill|上 下
automotive|suv.side.arrowtriangle.up.fill|上
automotive|suv.side.fill|
automotive|suv.side.front.open|
automotive|suv.side.front.open.crop|
automotive|suv.side.front.open.crop.fill|
automotive|suv.side.front.open.fill|
automotive|suv.side.hill.descent.control|
automotive|suv.side.hill.descent.control.fill|
automotive|suv.side.hill.down|下
automotive|suv.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle|下
automotive|suv.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle.fill|下
automotive|suv.side.hill.down.fill|下
automotive|suv.side.hill.up|上
automotive|suv.side.hill.up.fill|上
automotive|suv.side.lock|鎖 鎖定
automotive|suv.side.lock.fill|鎖 鎖定
automotive|suv.side.lock.open|鎖 鎖定 解鎖
automotive|suv.side.lock.open.fill|鎖 鎖定 解鎖
automotive|suv.side.rear.open|
automotive|suv.side.rear.open.crop|
automotive|suv.side.rear.open.crop.fill|
automotive|suv.side.rear.open.fill|
automotive|suv.side.roof.cargo.carrier|
automotive|suv.side.roof.cargo.carrier.fill|
automotive|suv.side.roof.cargo.carrier.slash|正斜線
automotive|suv.side.roof.cargo.carrier.slash.fill|正斜線
automotive|tachometer|
automotive|taillight.fog|有霧
automotive|taillight.fog.fill|有霧
automotive|thermometer.and.liquid.waves|溫度計 溫度 波浪
automotive|thermometer.and.liquid.waves.snowflake|溫度計 溫度 波浪 雪花
automotive|thermometer.and.liquid.waves.trianglebadge.exclamationmark|溫度計 溫度 波浪 驚嘆號 警告
automotive|thermometer.brakesignal|溫度計 溫度
automotive|thermometer.tirepressure|溫度計 溫度
automotive|thermometer.transmission|溫度計 溫度
automotive|tire|
automotive|tire.badge.snowflake|雪花
automotive|tirepressure|
automotive|tow.hitch|
automotive|tow.hitch.exclamationmark|驚嘆號 警告
automotive|tow.hitch.exclamationmark.fill|驚嘆號 警告
automotive|tow.hitch.fill|
automotive|traction.control.tirepressure|
automotive|traction.control.tirepressure.exclamationmark|驚嘆號 警告
automotive|traction.control.tirepressure.slash|正斜線
automotive|transmission|
automotive|truck.pickup.side|
automotive|truck.pickup.side.air.circulate|
automotive|truck.pickup.side.air.circulate.fill|
automotive|truck.pickup.side.air.fresh|
automotive|truck.pickup.side.air.fresh.fill|
automotive|truck.pickup.side.and.exclamationmark|驚嘆號 警告
automotive|truck.pickup.side.and.exclamationmark.fill|驚嘆號 警告
automotive|truck.pickup.side.arrow.left.and.right|箭頭 左 右
automotive|truck.pickup.side.arrow.left.and.right.fill|箭頭 左 右
automotive|truck.pickup.side.arrowtriangle.down|下
automotive|truck.pickup.side.arrowtriangle.down.fill|下
automotive|truck.pickup.side.arrowtriangle.up|上
automotive|truck.pickup.side.arrowtriangle.up.arrowtriangle.down|上 下
automotive|truck.pickup.side.arrowtriangle.up.arrowtriangle.down.fill|上 下
automotive|truck.pickup.side.arrowtriangle.up.fill|上
automotive|truck.pickup.side.fill|
automotive|truck.pickup.side.front.open|
automotive|truck.pickup.side.front.open.crop|
automotive|truck.pickup.side.front.open.crop.fill|
automotive|truck.pickup.side.front.open.fill|
automotive|truck.pickup.side.hill.down|下
automotive|truck.pickup.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle|下
automotive|truck.pickup.side.hill.down.and.gauge.open.with.lines.needle.25percent.and.arrowtriangle.fill|下
automotive|truck.pickup.side.hill.down.fill|下
automotive|truck.pickup.side.hill.up|上
automotive|truck.pickup.side.hill.up.fill|上
automotive|truck.pickup.side.lock|鎖 鎖定
automotive|truck.pickup.side.lock.fill|鎖 鎖定
automotive|truck.pickup.side.lock.open|鎖 鎖定 解鎖
automotive|truck.pickup.side.lock.open.fill|鎖 鎖定 解鎖
automotive|truck.side.hill.descent.control|
automotive|truck.side.hill.descent.control.fill|
automotive|truck.side.roof.cargo.carrier|
automotive|truck.side.roof.cargo.carrier.fill|
automotive|truck.side.roof.cargo.carrier.slash|正斜線
automotive|truck.side.roof.cargo.carrier.slash.fill|正斜線
automotive|tsa|
automotive|tsa.circle|圓形
automotive|tsa.circle.fill|圓形
automotive|tsa.slash|正斜線
automotive|vent.airflow.diffused|
automotive|vent.airflow.focused|
automotive|vent.airflow.manual|
automotive|vent.airflow.oscillating|
automotive|warninglight|
automotive|warninglight.fill|
automotive|wave.3.down.car.side|下 汽車 車
automotive|wave.3.down.car.side.fill|下 汽車 車
automotive|wave.3.down.convertible.side|下
automotive|wave.3.down.convertible.side.fill|下
automotive|wave.3.down.pickup.side|下
automotive|wave.3.down.pickup.side.fill|下
automotive|wave.3.down.suv.side|下
automotive|wave.3.down.suv.side.fill|下
automotive|windshield.front.and.fluid.and.spray|
automotive|windshield.front.and.heat.waves|波浪
automotive|windshield.front.and.spray|
automotive|windshield.front.and.wiper|
automotive|windshield.front.and.wiper.and.drop|水滴
automotive|windshield.front.and.wiper.and.spray|
automotive|windshield.front.and.wiper.exclamationmark|驚嘆號 警告
automotive|windshield.front.and.wiper.intermittent|
automotive|windshield.rear.and.fluid.and.spray|
automotive|windshield.rear.and.heat.waves|波浪
automotive|windshield.rear.and.spray|
automotive|windshield.rear.and.wiper|
automotive|windshield.rear.and.wiper.and.drop|水滴
automotive|windshield.rear.and.wiper.and.spray|
automotive|windshield.rear.and.wiper.exclamationmark|驚嘆號 警告
automotive|windshield.rear.and.wiper.intermittent|
automotive|wrongwaysign|
automotive|wrongwaysign.fill|
automotive|yieldsign|
automotive|yieldsign.fill|
objectsandtools|1.calendar|日曆 日期
objectsandtools|1.magnifyingglass|放大鏡 搜尋
objectsandtools|10.calendar|日曆 日期
objectsandtools|11.calendar|日曆 日期
objectsandtools|12.calendar|日曆 日期
objectsandtools|13.calendar|日曆 日期
objectsandtools|14.calendar|日曆 日期
objectsandtools|15.calendar|日曆 日期
objectsandtools|16.calendar|日曆 日期
objectsandtools|17.calendar|日曆 日期
objectsandtools|18.calendar|日曆 日期
objectsandtools|19.calendar|日曆 日期
objectsandtools|2.calendar|日曆 日期
objectsandtools|20.calendar|日曆 日期
objectsandtools|21.calendar|日曆 日期
objectsandtools|22.calendar|日曆 日期
objectsandtools|23.calendar|日曆 日期
objectsandtools|24.calendar|日曆 日期
objectsandtools|25.calendar|日曆 日期
objectsandtools|26.calendar|日曆 日期
objectsandtools|27.calendar|日曆 日期
objectsandtools|28.calendar|日曆 日期
objectsandtools|29.calendar|日曆 日期
objectsandtools|3.calendar|日曆 日期
objectsandtools|30.calendar|日曆 日期
objectsandtools|31.calendar|日曆 日期
objectsandtools|4.calendar|日曆 日期
objectsandtools|5.calendar|日曆 日期
objectsandtools|6.calendar|日曆 日期
objectsandtools|7.calendar|日曆 日期
objectsandtools|8.calendar|日曆 日期
objectsandtools|9.calendar|日曆 日期
objectsandtools|alarm|鬧鐘
objectsandtools|alarm.badge.exclamationmark|鬧鐘 驚嘆號 警告
objectsandtools|alarm.badge.exclamationmark.fill|鬧鐘 驚嘆號 警告
objectsandtools|alarm.badge.minus|鬧鐘 減號
objectsandtools|alarm.badge.minus.fill|鬧鐘 減號
objectsandtools|alarm.badge.xmark|鬧鐘 叉 關閉
objectsandtools|alarm.badge.xmark.fill|鬧鐘 叉 關閉
objectsandtools|alarm.fill|鬧鐘
objectsandtools|alarm.slash|鬧鐘 正斜線
objectsandtools|alarm.slash.fill|鬧鐘 正斜線
objectsandtools|alarm.waves.left.and.right|鬧鐘 波浪 左 右
objectsandtools|alarm.waves.left.and.right.fill|鬧鐘 波浪 左 右
objectsandtools|amplifier|
objectsandtools|archivebox|收納盒 郵件
objectsandtools|archivebox.circle|收納盒 圓形
objectsandtools|archivebox.circle.fill|收納盒 圓形
objectsandtools|archivebox.fill|收納盒 郵件
objectsandtools|arrow.down.document|箭頭 下
objectsandtools|arrow.down.document.fill|箭頭 下
objectsandtools|arrow.forward.folder|箭頭 快轉 資料夾
objectsandtools|arrow.forward.folder.fill|箭頭 快轉 資料夾
objectsandtools|arrow.right.page.on.clipboard|箭頭 右 寫字夾板
objectsandtools|arrow.trianglehead.2.clockwise.rotate.90.page.on.clipboard|箭頭 寫字夾板
objectsandtools|arrow.up.bin|箭頭 上 郵件
objectsandtools|arrow.up.bin.fill|箭頭 上 郵件
objectsandtools|arrow.up.document|箭頭 上
objectsandtools|arrow.up.document.fill|箭頭 上
objectsandtools|arrow.up.folder|箭頭 上 資料夾
objectsandtools|arrow.up.folder.fill|箭頭 上 資料夾
objectsandtools|arrow.up.left.and.down.right.magnifyingglass|箭頭 上 左 下 右 放大鏡 搜尋
objectsandtools|arrow.up.page.on.clipboard|箭頭 上 寫字夾板
objectsandtools|arrow.up.trash|箭頭 上 垃圾桶 刪除
objectsandtools|arrow.up.trash.fill|箭頭 上 垃圾桶 刪除
objectsandtools|backpack|背包 露營
objectsandtools|backpack.circle|背包 圓形 露營
objectsandtools|backpack.circle.fill|背包 圓形 露營
objectsandtools|backpack.fill|背包 露營
objectsandtools|barometer|
objectsandtools|battery.0percent|電池
objectsandtools|battery.100percent|電池
objectsandtools|battery.100percent.bolt|電池 閃電
objectsandtools|battery.100percent.circle|電池 圓形
objectsandtools|battery.100percent.circle.fill|電池 圓形
objectsandtools|battery.25percent|電池
objectsandtools|battery.50percent|電池
objectsandtools|battery.75percent|電池
objectsandtools|beach.umbrella|雨傘
objectsandtools|beach.umbrella.fill|雨傘
objectsandtools|bell|鈴 通知 郵件
objectsandtools|bell.and.waves.left.and.right|鈴 通知 波浪 左 右
objectsandtools|bell.and.waves.left.and.right.fill|鈴 通知 波浪 左 右
objectsandtools|bell.badge|鈴 通知
objectsandtools|bell.badge.circle|鈴 通知 圓形
objectsandtools|bell.badge.circle.fill|鈴 通知 圓形
objectsandtools|bell.badge.fill|鈴 通知
objectsandtools|bell.badge.slash|鈴 通知 正斜線
objectsandtools|bell.badge.slash.fill|鈴 通知 正斜線
objectsandtools|bell.badge.waveform|鈴 通知
objectsandtools|bell.badge.waveform.fill|鈴 通知
objectsandtools|bell.badge.waveform.slash|鈴 通知 正斜線
objectsandtools|bell.badge.waveform.slash.fill|鈴 通知 正斜線
objectsandtools|bell.circle|鈴 通知 圓形 郵件
objectsandtools|bell.circle.fill|鈴 通知 圓形 郵件
objectsandtools|bell.fill|鈴 通知 郵件
objectsandtools|bell.slash|鈴 通知 正斜線 郵件
objectsandtools|bell.slash.circle|鈴 通知 正斜線 圓形
objectsandtools|bell.slash.circle.fill|鈴 通知 正斜線 圓形
objectsandtools|bell.slash.fill|鈴 通知 正斜線 郵件
objectsandtools|bell.square|鈴 通知 方形
objectsandtools|bell.square.fill|鈴 通知 方形
objectsandtools|birthday.cake|生日 蛋糕
objectsandtools|birthday.cake.fill|生日 蛋糕
objectsandtools|book|書 書本 書籤
objectsandtools|book.badge.plus|書 書本 加號 新增
objectsandtools|book.badge.plus.fill|書 書本 加號 新增
objectsandtools|book.circle|書 書本 圓形 書籤
objectsandtools|book.circle.fill|書 書本 圓形 書籤
objectsandtools|book.closed|書 書本
objectsandtools|book.closed.circle|書 書本 圓形
objectsandtools|book.closed.circle.fill|書 書本 圓形
objectsandtools|book.closed.fill|書 書本
objectsandtools|book.fill|書 書本 書籤
objectsandtools|bookmark|書籤
objectsandtools|bookmark.circle|書籤 圓形
objectsandtools|bookmark.circle.fill|書籤 圓形
objectsandtools|bookmark.fill|書籤
objectsandtools|bookmark.slash|書籤 正斜線
objectsandtools|bookmark.slash.fill|書籤 正斜線
objectsandtools|bookmark.square|書籤 方形
objectsandtools|bookmark.square.fill|書籤 方形
objectsandtools|books.vertical|書
objectsandtools|books.vertical.circle|書 圓形
objectsandtools|books.vertical.circle.fill|書 圓形
objectsandtools|books.vertical.fill|書
objectsandtools|briefcase|公事包
objectsandtools|briefcase.circle|公事包 圓形
objectsandtools|briefcase.circle.fill|公事包 圓形
objectsandtools|briefcase.fill|公事包
objectsandtools|building|
objectsandtools|building.2|
objectsandtools|building.2.crop.circle|圓形
objectsandtools|building.2.crop.circle.fill|圓形
objectsandtools|building.2.fill|
objectsandtools|building.fill|
objectsandtools|calendar|日曆 日期
objectsandtools|calendar.badge|日曆 日期
objectsandtools|calendar.badge.checkmark|日曆 日期 勾 勾選
objectsandtools|calendar.badge.clock|日曆 日期 時鐘 時間
objectsandtools|calendar.badge.exclamationmark|日曆 日期 驚嘆號 警告
objectsandtools|calendar.badge.lock|日曆 日期 鎖 鎖定
objectsandtools|calendar.badge.minus|日曆 日期 減號
objectsandtools|calendar.badge.plus|日曆 日期 加號 新增
objectsandtools|calendar.circle|日曆 日期 圓形
objectsandtools|calendar.circle.fill|日曆 日期 圓形
objectsandtools|calendar.day|日曆 日期
objectsandtools|case|
objectsandtools|case.fill|
objectsandtools|character.book.closed|書 書本
objectsandtools|character.book.closed.fill|書 書本
objectsandtools|character.book.closed.fill.mni|書 書本
objectsandtools|character.book.closed.mni|書 書本
objectsandtools|chart.xyaxis.line|圖表
objectsandtools|checkmark.shield|勾 勾選 盾牌
objectsandtools|checkmark.shield.fill|勾 勾選 盾牌
objectsandtools|clipboard|寫字夾板
objectsandtools|clipboard.fill|寫字夾板
objectsandtools|clock|時鐘 時間
objectsandtools|clock.arrow.trianglehead.clockwise.rotate.90.path.dotted|時鐘 時間 箭頭
objectsandtools|clock.badge|時鐘 時間
objectsandtools|clock.badge.airplane|時鐘 時間 飛機
objectsandtools|clock.badge.airplane.fill|時鐘 時間 飛機
objectsandtools|clock.badge.checkmark|時鐘 時間 勾 勾選
objectsandtools|clock.badge.checkmark.fill|時鐘 時間 勾 勾選
objectsandtools|clock.badge.exclamationmark|時鐘 時間 驚嘆號 警告
objectsandtools|clock.badge.exclamationmark.fill|時鐘 時間 驚嘆號 警告
objectsandtools|clock.badge.fill|時鐘 時間
objectsandtools|clock.badge.questionmark|時鐘 時間 問號
objectsandtools|clock.badge.questionmark.fill|時鐘 時間 問號
objectsandtools|clock.badge.xmark|時鐘 時間 叉 關閉
objectsandtools|clock.badge.xmark.fill|時鐘 時間 叉 關閉
objectsandtools|clock.circle|時鐘 時間 圓形
objectsandtools|clock.circle.fill|時鐘 時間 圓形
objectsandtools|clock.fill|時鐘 時間
objectsandtools|coat|外套
objectsandtools|coat.fill|外套
objectsandtools|comb|
objectsandtools|comb.fill|
objectsandtools|cpu|
objectsandtools|cpu.fill|
objectsandtools|creditcard.viewfinder|信用卡
objectsandtools|crown|皇冠
objectsandtools|crown.fill|皇冠
objectsandtools|cube|
objectsandtools|cube.badge.paintbrush|畫筆 刷子
objectsandtools|cube.badge.paintbrush.fill|畫筆 刷子
objectsandtools|cube.circle|圓形
objectsandtools|cube.circle.fill|圓形
objectsandtools|cube.fill|
objectsandtools|cube.plane.bottom.right.detached|右
objectsandtools|cube.plane.bottom.right.detached.fill|右
objectsandtools|cup.and.heat.waves|杯子 波浪
objectsandtools|cup.and.heat.waves.fill|杯子 波浪
objectsandtools|cup.and.saucer|杯子
objectsandtools|cup.and.saucer.fill|杯子
objectsandtools|deskclock|
objectsandtools|deskclock.fill|
objectsandtools|dice|
objectsandtools|dice.fill|
objectsandtools|die.face.1|臉
objectsandtools|die.face.1.fill|臉
objectsandtools|die.face.2|臉
objectsandtools|die.face.2.fill|臉
objectsandtools|die.face.3|臉
objectsandtools|die.face.3.fill|臉
objectsandtools|die.face.4|臉
objectsandtools|die.face.4.fill|臉
objectsandtools|die.face.5|臉
objectsandtools|die.face.5.fill|臉
objectsandtools|die.face.6|臉
objectsandtools|die.face.6.fill|臉
objectsandtools|document|
objectsandtools|document.badge.arrow.up|箭頭 上
objectsandtools|document.badge.arrow.up.fill|箭頭 上
objectsandtools|document.badge.clock|時鐘 時間
objectsandtools|document.badge.clock.fill|時鐘 時間
objectsandtools|document.badge.ellipsis|省略號
objectsandtools|document.badge.ellipsis.fill|省略號
objectsandtools|document.badge.gearshape|設定 齒輪
objectsandtools|document.badge.gearshape.fill|設定 齒輪
objectsandtools|document.badge.plus|加號 新增
objectsandtools|document.badge.plus.fill|加號 新增
objectsandtools|document.circle|圓形
objectsandtools|document.circle.fill|圓形
objectsandtools|document.fill|
objectsandtools|document.on.clipboard|寫字夾板
objectsandtools|document.on.clipboard.fill|寫字夾板
objectsandtools|document.on.document|
objectsandtools|document.on.document.fill|
objectsandtools|document.on.trash|垃圾桶 刪除
objectsandtools|document.on.trash.fill|垃圾桶 刪除
objectsandtools|document.viewfinder|
objectsandtools|document.viewfinder.fill|
objectsandtools|drone|
objectsandtools|drone.fill|
objectsandtools|ellipsis.calendar|省略號 日曆 日期
objectsandtools|esim|
objectsandtools|esim.fill|
objectsandtools|exclamationmark.lock|驚嘆號 警告 鎖 鎖定
objectsandtools|exclamationmark.lock.fill|驚嘆號 警告 鎖 鎖定
objectsandtools|exclamationmark.magnifyingglass|驚嘆號 警告 放大鏡 搜尋
objectsandtools|exclamationmark.shield|驚嘆號 警告 盾牌
objectsandtools|exclamationmark.shield.fill|驚嘆號 警告 盾牌
objectsandtools|externaldrive|外接硬碟
objectsandtools|externaldrive.badge.checkmark|外接硬碟 勾 勾選
objectsandtools|externaldrive.badge.exclamationmark|外接硬碟 驚嘆號 警告
objectsandtools|externaldrive.badge.icloud|外接硬碟
objectsandtools|externaldrive.badge.minus|外接硬碟 減號
objectsandtools|externaldrive.badge.plus|外接硬碟 加號 新增
objectsandtools|externaldrive.badge.questionmark|外接硬碟 問號
objectsandtools|externaldrive.badge.timemachine|外接硬碟
objectsandtools|externaldrive.badge.wifi|外接硬碟 無線網路
objectsandtools|externaldrive.badge.xmark|外接硬碟 叉 關閉
objectsandtools|externaldrive.fill|外接硬碟
objectsandtools|externaldrive.fill.badge.checkmark|外接硬碟 勾 勾選
objectsandtools|externaldrive.fill.badge.exclamationmark|外接硬碟 驚嘆號 警告
objectsandtools|externaldrive.fill.badge.icloud|外接硬碟
objectsandtools|externaldrive.fill.badge.minus|外接硬碟 減號
objectsandtools|externaldrive.fill.badge.plus|外接硬碟 加號 新增
objectsandtools|externaldrive.fill.badge.questionmark|外接硬碟 問號
objectsandtools|externaldrive.fill.badge.timemachine|外接硬碟
objectsandtools|externaldrive.fill.badge.wifi|外接硬碟 無線網路
objectsandtools|externaldrive.fill.badge.xmark|外接硬碟 叉 關閉
objectsandtools|externaldrive.fill.trianglebadge.exclamationmark|外接硬碟 驚嘆號 警告
objectsandtools|externaldrive.trianglebadge.exclamationmark|外接硬碟 驚嘆號 警告
objectsandtools|eyeglasses|
objectsandtools|eyeglasses.slash|正斜線
objectsandtools|film|底片 電影
objectsandtools|film.circle|底片 電影 圓形
objectsandtools|film.circle.fill|底片 電影 圓形
objectsandtools|film.fill|底片 電影
objectsandtools|film.stack|底片 電影
objectsandtools|film.stack.fill|底片 電影
objectsandtools|fire.extinguisher|火
objectsandtools|fire.extinguisher.fill|火
objectsandtools|fireworks|爆竹 派對
objectsandtools|flag|旗幟 旗 郵件
objectsandtools|flag.badge.ellipsis|旗幟 旗 省略號
objectsandtools|flag.badge.ellipsis.fill|旗幟 旗 省略號
objectsandtools|flag.circle|旗幟 旗 圓形 郵件
objectsandtools|flag.circle.fill|旗幟 旗 圓形 郵件
objectsandtools|flag.fill|旗幟 旗 郵件
objectsandtools|flag.slash|旗幟 旗 正斜線 郵件
objectsandtools|flag.slash.circle|旗幟 旗 正斜線 圓形
objectsandtools|flag.slash.circle.fill|旗幟 旗 正斜線 圓形
objectsandtools|flag.slash.fill|旗幟 旗 正斜線 郵件
objectsandtools|flag.square|旗幟 旗 方形
objectsandtools|flag.square.fill|旗幟 旗 方形
objectsandtools|flashlight.off.circle|手電筒 圓形
objectsandtools|flashlight.off.circle.fill|手電筒 圓形
objectsandtools|flashlight.off.fill|手電筒
objectsandtools|flashlight.on.circle|手電筒 圓形
objectsandtools|flashlight.on.circle.fill|手電筒 圓形
objectsandtools|flashlight.on.fill|手電筒
objectsandtools|flashlight.slash|手電筒 正斜線
objectsandtools|flashlight.slash.circle|手電筒 正斜線 圓形
objectsandtools|flashlight.slash.circle.fill|手電筒 正斜線 圓形
objectsandtools|flask|
objectsandtools|flask.fill|
objectsandtools|folder|資料夾
objectsandtools|folder.badge.gearshape|資料夾 設定 齒輪
objectsandtools|folder.badge.minus|資料夾 減號
objectsandtools|folder.badge.plus|資料夾 加號 新增
objectsandtools|folder.badge.questionmark|資料夾 問號
objectsandtools|folder.circle|資料夾 圓形
objectsandtools|folder.circle.fill|資料夾 圓形
objectsandtools|folder.fill|資料夾
objectsandtools|folder.fill.badge.gearshape|資料夾 設定 齒輪
objectsandtools|folder.fill.badge.minus|資料夾 減號
objectsandtools|folder.fill.badge.plus|資料夾 加號 新增
objectsandtools|folder.fill.badge.questionmark|資料夾 問號
objectsandtools|fork.knife|叉子 餐廳 刀
objectsandtools|fork.knife.circle|叉子 餐廳 刀 圓形
objectsandtools|fork.knife.circle.fill|叉子 餐廳 刀 圓形
objectsandtools|gauge.range.33to100.dotted.with.needle|計時器
objectsandtools|gear|齒輪 設定
objectsandtools|gearshape|設定 齒輪
objectsandtools|gearshape.2|設定 齒輪
objectsandtools|gearshape.2.fill|設定 齒輪
objectsandtools|gearshape.fill|設定 齒輪
objectsandtools|gift|禮物 生日
objectsandtools|gift.circle|禮物 圓形 生日
objectsandtools|gift.circle.fill|禮物 圓形 生日
objectsandtools|gift.fill|禮物 生日
objectsandtools|globe.desk|地球
objectsandtools|globe.desk.fill|地球
objectsandtools|graduationcap|畢業帽 學校 學生
objectsandtools|graduationcap.circle|畢業帽 學校 圓形 學生
objectsandtools|graduationcap.circle.fill|畢業帽 學校 圓形 學生
objectsandtools|graduationcap.fill|畢業帽 學校 學生
objectsandtools|greetingcard|
objectsandtools|greetingcard.fill|
objectsandtools|guitars|吉他
objectsandtools|guitars.fill|吉他
objectsandtools|gyroscope|
objectsandtools|hammer|鎚子 工具
objectsandtools|hammer.circle|鎚子 工具 圓形
objectsandtools|hammer.circle.fill|鎚子 工具 圓形
objectsandtools|hammer.fill|鎚子 工具
objectsandtools|hammer.slash|鎚子 工具 正斜線
objectsandtools|hammer.slash.fill|鎚子 工具 正斜線
objectsandtools|handbag|手提包
objectsandtools|handbag.circle|手提包 圓形
objectsandtools|handbag.circle.fill|手提包 圓形
objectsandtools|handbag.fill|手提包
objectsandtools|hanger|
objectsandtools|hat.cap|棒球
objectsandtools|hat.cap.fill|棒球
objectsandtools|hat.widebrim|
objectsandtools|hat.widebrim.fill|
objectsandtools|helmet|
objectsandtools|helmet.fill|
objectsandtools|hourglass|沙漏
objectsandtools|hourglass.badge.eye|沙漏 眼睛
objectsandtools|hourglass.badge.lock|沙漏 鎖 鎖定
objectsandtools|hourglass.badge.plus|沙漏 加號 新增
objectsandtools|hourglass.bottomhalf.filled|沙漏
objectsandtools|hourglass.circle|沙漏 圓形
objectsandtools|hourglass.circle.fill|沙漏 圓形
objectsandtools|hourglass.tophalf.filled|沙漏
objectsandtools|house.and.flag|房子 家 首頁 旗幟 旗 露營 車站
objectsandtools|house.and.flag.circle|房子 家 首頁 旗幟 旗 圓形 露營 車站
objectsandtools|house.and.flag.circle.fill|房子 家 首頁 旗幟 旗 圓形 露營 車站
objectsandtools|house.and.flag.fill|房子 家 首頁 旗幟 旗 露營 車站
objectsandtools|house.lodge|房子 家 首頁 露營
objectsandtools|house.lodge.circle|房子 家 首頁 圓形 露營
objectsandtools|house.lodge.circle.fill|房子 家 首頁 圓形 露營
objectsandtools|house.lodge.fill|房子 家 首頁 露營
objectsandtools|inhaler|
objectsandtools|inhaler.fill|
objectsandtools|internaldrive|
objectsandtools|internaldrive.fill|
objectsandtools|jacket|
objectsandtools|jacket.fill|
objectsandtools|key.2.on.ring|鑰匙 戒指
objectsandtools|key.2.on.ring.fill|鑰匙 戒指
objectsandtools|key.viewfinder|鑰匙
objectsandtools|lanyardcard|
objectsandtools|lanyardcard.fill|
objectsandtools|laser.burst|派對
objectsandtools|latch.2.case|
objectsandtools|latch.2.case.fill|
objectsandtools|level|
objectsandtools|level.fill|
objectsandtools|lifepreserver|
objectsandtools|lifepreserver.fill|
objectsandtools|link|連結
objectsandtools|link.badge.plus|連結 加號 新增
objectsandtools|link.circle|連結 圓形
objectsandtools|link.circle.fill|連結 圓形
objectsandtools|location.magnifyingglass|位置 定位 放大鏡 搜尋
objectsandtools|lock|鎖 鎖定
objectsandtools|lock.badge.checkmark|鎖 鎖定 勾 勾選
objectsandtools|lock.badge.checkmark.fill|鎖 鎖定 勾 勾選
objectsandtools|lock.badge.clock|鎖 鎖定 時鐘 時間
objectsandtools|lock.badge.clock.fill|鎖 鎖定 時鐘 時間
objectsandtools|lock.badge.xmark|鎖 鎖定 叉 關閉
objectsandtools|lock.badge.xmark.fill|鎖 鎖定 叉 關閉
objectsandtools|lock.circle|鎖 鎖定 圓形
objectsandtools|lock.circle.dotted|鎖 鎖定 圓形
objectsandtools|lock.circle.fill|鎖 鎖定 圓形
objectsandtools|lock.document|鎖 鎖定
objectsandtools|lock.document.fill|鎖 鎖定
objectsandtools|lock.fill|鎖 鎖定
objectsandtools|lock.open|鎖 鎖定 解鎖
objectsandtools|lock.open.fill|鎖 鎖定 解鎖
objectsandtools|lock.open.rotation|鎖 鎖定
objectsandtools|lock.rectangle|鎖 鎖定 長方形
objectsandtools|lock.rectangle.fill|鎖 鎖定 長方形
objectsandtools|lock.rectangle.on.rectangle|鎖 鎖定 長方形
objectsandtools|lock.rectangle.on.rectangle.fill|鎖 鎖定 長方形
objectsandtools|lock.rectangle.stack|鎖 鎖定 長方形
objectsandtools|lock.rectangle.stack.fill|鎖 鎖定 長方形
objectsandtools|lock.rotation|鎖 鎖定
objectsandtools|lock.shield|鎖 鎖定 盾牌
objectsandtools|lock.shield.fill|鎖 鎖定 盾牌
objectsandtools|lock.slash|鎖 鎖定 正斜線
objectsandtools|lock.slash.fill|鎖 鎖定 正斜線
objectsandtools|lock.square|鎖 鎖定 方形
objectsandtools|lock.square.dashed|鎖 鎖定 方形
objectsandtools|lock.square.fill|鎖 鎖定 方形
objectsandtools|lock.square.stack|鎖 鎖定 方形
objectsandtools|lock.square.stack.fill|鎖 鎖定 方形
objectsandtools|magazine|
objectsandtools|magazine.fill|
objectsandtools|magnifyingglass|放大鏡 搜尋
objectsandtools|magnifyingglass.circle|放大鏡 搜尋 圓形
objectsandtools|magnifyingglass.circle.fill|放大鏡 搜尋 圓形
objectsandtools|medal.star|獎牌 星星 星
objectsandtools|medal.star.fill|獎牌 星星 星
objectsandtools|megaphone|擴音器
objectsandtools|megaphone.fill|擴音器
objectsandtools|memorychip|
objectsandtools|memorychip.fill|
objectsandtools|menucard|
objectsandtools|menucard.fill|
objectsandtools|metronome|
objectsandtools|metronome.fill|
objectsandtools|microphone.dynamic.on.stand|麥克風
objectsandtools|microphone.dynamic.on.stand.circle|麥克風 圓形
objectsandtools|microphone.dynamic.on.stand.circle.fill|麥克風 圓形
objectsandtools|movieclapper|
objectsandtools|movieclapper.fill|
objectsandtools|mug|馬克杯 咖啡
objectsandtools|mug.fill|馬克杯 咖啡
objectsandtools|newspaper|報紙
objectsandtools|newspaper.circle|報紙 圓形
objectsandtools|newspaper.circle.fill|報紙 圓形
objectsandtools|newspaper.fill|報紙
objectsandtools|opticaldisc|
objectsandtools|opticaldisc.fill|
objectsandtools|opticaldiscdrive|
objectsandtools|opticaldiscdrive.fill|
objectsandtools|pad.header|
objectsandtools|paintpalette|
objectsandtools|paintpalette.fill|
objectsandtools|paperclip|迴紋針 郵件
objectsandtools|paperclip.badge.ellipsis|迴紋針 省略號
objectsandtools|paperclip.circle|迴紋針 圓形
objectsandtools|paperclip.circle.fill|迴紋針 圓形
objectsandtools|paperplane|
objectsandtools|paperplane.circle|圓形
objectsandtools|paperplane.circle.fill|圓形
objectsandtools|paperplane.fill|
objectsandtools|pencil.and.ruler|鉛筆 尺
objectsandtools|pencil.and.ruler.fill|鉛筆 尺
objectsandtools|pet.carrier|行李
objectsandtools|pet.carrier.circle|圓形 行李
objectsandtools|pet.carrier.circle.fill|圓形 行李
objectsandtools|pet.carrier.fill|行李
objectsandtools|photo.artframe|照片 相片 山 太陽
objectsandtools|photo.artframe.circle|照片 相片 圓形 山 太陽
objectsandtools|photo.artframe.circle.fill|照片 相片 圓形 山 太陽
objectsandtools|pianokeys|鋼琴
objectsandtools|pianokeys.inverse|鋼琴
objectsandtools|pin|圖釘
objectsandtools|pin.circle|圖釘 圓形
objectsandtools|pin.circle.fill|圖釘 圓形
objectsandtools|pin.fill|圖釘
objectsandtools|pin.slash|圖釘 正斜線
objectsandtools|pin.slash.fill|圖釘 正斜線
objectsandtools|pin.square|圖釘 方形
objectsandtools|pin.square.fill|圖釘 方形
objectsandtools|pizza.slice|披薩
objectsandtools|pizza.slice.fill|披薩
objectsandtools|plus.rectangle.on.folder|加號 新增 長方形 資料夾
objectsandtools|plus.rectangle.on.folder.fill|加號 新增 長方形 資料夾
objectsandtools|powerplug|
objectsandtools|powerplug.fill|
objectsandtools|powerplug.portrait|
objectsandtools|powerplug.portrait.fill|
objectsandtools|puzzlepiece|
objectsandtools|puzzlepiece.extension|
objectsandtools|puzzlepiece.extension.fill|
objectsandtools|puzzlepiece.fill|
objectsandtools|questionmark.folder|問號 資料夾
objectsandtools|questionmark.folder.fill|問號 資料夾
objectsandtools|radio|收音機
objectsandtools|radio.fill|收音機
objectsandtools|receipt|收據
objectsandtools|receipt.fill|收據
objectsandtools|rectangle.and.paperclip|長方形 迴紋針
objectsandtools|rectangle.dashed.and.paperclip|長方形 迴紋針
objectsandtools|rosette|獎章
objectsandtools|ruler|尺
objectsandtools|ruler.fill|尺
objectsandtools|sailboat|帆船
objectsandtools|sailboat.circle|帆船 圓形
objectsandtools|sailboat.circle.fill|帆船 圓形
objectsandtools|sailboat.fill|帆船
objectsandtools|scalemass|
objectsandtools|scalemass.fill|
objectsandtools|screwdriver|螺絲起子
objectsandtools|screwdriver.fill|螺絲起子
objectsandtools|scroll|捲軸
objectsandtools|scroll.fill|捲軸
objectsandtools|sdcard|
objectsandtools|sdcard.fill|
objectsandtools|sensor.tag.radiowaves.forward|標籤 快轉 位置 定位
objectsandtools|sensor.tag.radiowaves.forward.fill|標籤 快轉 位置 定位
objectsandtools|shield|盾牌
objectsandtools|shield.fill|盾牌
objectsandtools|shield.lefthalf.filled|盾牌
objectsandtools|shield.lefthalf.filled.badge.checkmark|盾牌 勾 勾選
objectsandtools|shield.lefthalf.filled.slash|盾牌 正斜線
objectsandtools|shield.lefthalf.filled.trianglebadge.exclamationmark|盾牌 驚嘆號 警告
objectsandtools|shield.pattern.checkered|盾牌
objectsandtools|shield.righthalf.filled|盾牌
objectsandtools|shield.slash|盾牌 正斜線
objectsandtools|shield.slash.fill|盾牌 正斜線
objectsandtools|shippingbox|箱子 包裹
objectsandtools|shippingbox.and.arrow.backward|箱子 包裹 箭頭 倒轉
objectsandtools|shippingbox.and.arrow.backward.fill|箱子 包裹 箭頭 倒轉
objectsandtools|shippingbox.circle|箱子 包裹 圓形
objectsandtools|shippingbox.circle.fill|箱子 包裹 圓形
objectsandtools|shippingbox.fill|箱子 包裹
objectsandtools|shoe|
objectsandtools|shoe.2|
objectsandtools|shoe.2.fill|
objectsandtools|shoe.circle|圓形
objectsandtools|shoe.circle.fill|圓形
objectsandtools|shoe.fill|
objectsandtools|signpost.and.arrowtriangle.up|上 露營
objectsandtools|signpost.and.arrowtriangle.up.circle|上 圓形 露營
objectsandtools|signpost.and.arrowtriangle.up.circle.fill|上 圓形 露營
objectsandtools|signpost.and.arrowtriangle.up.fill|上 露營
objectsandtools|signpost.left|左 露營
objectsandtools|signpost.left.circle|左 圓形 露營
objectsandtools|signpost.left.circle.fill|左 圓形 露營
objectsandtools|signpost.left.fill|左 露營
objectsandtools|signpost.right|右 露營
objectsandtools|signpost.right.and.left|右 左 露營 叉子 餐廳
objectsandtools|signpost.right.and.left.circle|右 左 圓形 露營 叉子 餐廳
objectsandtools|signpost.right.and.left.circle.fill|右 左 圓形 露營 叉子 餐廳
objectsandtools|signpost.right.and.left.fill|右 左 露營 叉子 餐廳
objectsandtools|signpost.right.circle|右 圓形 露營
objectsandtools|signpost.right.circle.fill|右 圓形 露營
objectsandtools|signpost.right.fill|右 露營
objectsandtools|simcard|
objectsandtools|simcard.2|
objectsandtools|simcard.2.fill|
objectsandtools|simcard.fill|
objectsandtools|sparkle.magnifyingglass|火花 放大鏡 搜尋
objectsandtools|speaker|喇叭 音量
objectsandtools|speaker.badge.exclamationmark|喇叭 音量 驚嘆號 警告
objectsandtools|speaker.badge.exclamationmark.fill|喇叭 音量 驚嘆號 警告
objectsandtools|speaker.circle|喇叭 音量 圓形
objectsandtools|speaker.circle.fill|喇叭 音量 圓形
objectsandtools|speaker.fill|喇叭 音量
objectsandtools|speaker.minus|喇叭 音量 減號
objectsandtools|speaker.minus.fill|喇叭 音量 減號
objectsandtools|speaker.plus|喇叭 音量 加號 新增
objectsandtools|speaker.plus.fill|喇叭 音量 加號 新增
objectsandtools|speaker.slash|喇叭 音量 正斜線
objectsandtools|speaker.slash.circle|喇叭 音量 正斜線 圓形
objectsandtools|speaker.slash.circle.fill|喇叭 音量 正斜線 圓形
objectsandtools|speaker.slash.fill|喇叭 音量 正斜線
objectsandtools|speaker.square|喇叭 音量 方形
objectsandtools|speaker.square.fill|喇叭 音量 方形
objectsandtools|speaker.trianglebadge.exclamationmark|喇叭 音量 驚嘆號 警告
objectsandtools|speaker.trianglebadge.exclamationmark.fill|喇叭 音量 驚嘆號 警告
objectsandtools|speaker.wave.1|喇叭 音量
objectsandtools|speaker.wave.1.arrowtriangles.up.right.down.left|喇叭 音量 上 右 下 左
objectsandtools|speaker.wave.1.fill|喇叭 音量
objectsandtools|speaker.wave.2|喇叭 音量
objectsandtools|speaker.wave.2.circle|喇叭 音量 圓形
objectsandtools|speaker.wave.2.circle.fill|喇叭 音量 圓形
objectsandtools|speaker.wave.2.fill|喇叭 音量
objectsandtools|speaker.wave.3|喇叭 音量
objectsandtools|speaker.wave.3.fill|喇叭 音量
objectsandtools|speaker.zzz|喇叭 音量 睡著
objectsandtools|speaker.zzz.fill|喇叭 音量 睡著
objectsandtools|spoon.serving|湯匙
objectsandtools|square.grid.3x1.folder.badge.plus|方形 格狀 資料夾 加號 新增
objectsandtools|square.grid.3x1.folder.fill.badge.plus|方形 格狀 資料夾 加號 新增
objectsandtools|star.calendar|星星 星 日曆 日期
objectsandtools|staroflife.shield|盾牌
objectsandtools|staroflife.shield.fill|盾牌
objectsandtools|stopwatch|碼錶
objectsandtools|stopwatch.fill|碼錶
objectsandtools|stroller|嬰兒車
objectsandtools|stroller.fill|嬰兒車
objectsandtools|studentdesk|
objectsandtools|suitcase|行李箱 旅行 行李
objectsandtools|suitcase.cart|行李箱 旅行 購物車 行李
objectsandtools|suitcase.cart.fill|行李箱 旅行 購物車 行李
objectsandtools|suitcase.fill|行李箱 旅行 行李
objectsandtools|suitcase.rolling|行李箱 旅行 行李
objectsandtools|suitcase.rolling.and.film|行李箱 旅行 底片 電影 行李
objectsandtools|suitcase.rolling.and.film.circle|行李箱 旅行 底片 電影 圓形 行李
objectsandtools|suitcase.rolling.and.film.circle.fill|行李箱 旅行 底片 電影 圓形 行李
objectsandtools|suitcase.rolling.and.film.fill|行李箱 旅行 底片 電影 行李
objectsandtools|suitcase.rolling.and.suitcase|行李箱 旅行 行李
objectsandtools|suitcase.rolling.and.suitcase.circle|行李箱 旅行 圓形 行李
objectsandtools|suitcase.rolling.and.suitcase.circle.fill|行李箱 旅行 圓形 行李
objectsandtools|suitcase.rolling.and.suitcase.fill|行李箱 旅行 行李
objectsandtools|suitcase.rolling.circle|行李箱 旅行 圓形 行李
objectsandtools|suitcase.rolling.circle.fill|行李箱 旅行 圓形 行李
objectsandtools|suitcase.rolling.fill|行李箱 旅行 行李
objectsandtools|sunglasses|太陽眼鏡
objectsandtools|sunglasses.fill|太陽眼鏡
objectsandtools|swatchpalette|
objectsandtools|swatchpalette.fill|
objectsandtools|tag|標籤
objectsandtools|tag.circle|標籤 圓形
objectsandtools|tag.circle.fill|標籤 圓形
objectsandtools|tag.fill|標籤
objectsandtools|tag.slash|標籤 正斜線
objectsandtools|tag.slash.fill|標籤 正斜線
objectsandtools|tag.square|標籤 方形
objectsandtools|tag.square.fill|標籤 方形
objectsandtools|takeoutbag.and.cup.and.straw|外帶 杯子
objectsandtools|takeoutbag.and.cup.and.straw.fill|外帶 杯子
objectsandtools|teddybear|泰迪熊
objectsandtools|teddybear.fill|泰迪熊
objectsandtools|tent|帳篷 露營
objectsandtools|tent.2|帳篷 露營
objectsandtools|tent.2.circle|帳篷 圓形 露營
objectsandtools|tent.2.circle.fill|帳篷 圓形 露營
objectsandtools|tent.2.fill|帳篷 露營
objectsandtools|tent.circle|帳篷 圓形 露營
objectsandtools|tent.circle.fill|帳篷 圓形 露營
objectsandtools|tent.fill|帳篷 露營
objectsandtools|testtube.2|試管
objectsandtools|text.below.folder|資料夾
objectsandtools|text.below.folder.fill|資料夾
objectsandtools|text.book.closed|書 書本
objectsandtools|text.book.closed.fill|書 書本
objectsandtools|text.document|
objectsandtools|text.document.fill|
objectsandtools|text.magnifyingglass|放大鏡 搜尋
objectsandtools|text.pad.header|
objectsandtools|text.pad.header.badge.clock|時鐘 時間
objectsandtools|text.pad.header.badge.plus|加號 新增
objectsandtools|text.page.badge.magnifyingglass|放大鏡 搜尋
objectsandtools|theatermask.and.paintbrush|畫筆 刷子
objectsandtools|theatermask.and.paintbrush.fill|畫筆 刷子
objectsandtools|theatermasks|戲劇
objectsandtools|theatermasks.circle|戲劇 圓形
objectsandtools|theatermasks.circle.fill|戲劇 圓形
objectsandtools|theatermasks.fill|戲劇
objectsandtools|ticket|票
objectsandtools|ticket.circle|票 圓形
objectsandtools|ticket.circle.fill|票 圓形
objectsandtools|ticket.fill|票
objectsandtools|timer|計時器
objectsandtools|timer.circle|計時器 圓形
objectsandtools|timer.circle.fill|計時器 圓形
objectsandtools|timer.square|計時器 方形
objectsandtools|trash|垃圾桶 刪除 郵件
objectsandtools|trash.circle|垃圾桶 刪除 圓形 郵件
objectsandtools|trash.circle.fill|垃圾桶 刪除 圓形 郵件
objectsandtools|trash.fill|垃圾桶 刪除 郵件
objectsandtools|trash.slash|垃圾桶 刪除 正斜線
objectsandtools|trash.slash.circle|垃圾桶 刪除 正斜線 圓形
objectsandtools|trash.slash.circle.fill|垃圾桶 刪除 正斜線 圓形
objectsandtools|trash.slash.fill|垃圾桶 刪除 正斜線
objectsandtools|trash.slash.square|垃圾桶 刪除 正斜線 方形
objectsandtools|trash.slash.square.fill|垃圾桶 刪除 正斜線 方形
objectsandtools|trash.square|垃圾桶 刪除 方形
objectsandtools|trash.square.fill|垃圾桶 刪除 方形
objectsandtools|tray|托盤 收件匣 郵件
objectsandtools|tray.2|托盤 收件匣 郵件
objectsandtools|tray.2.fill|托盤 收件匣 郵件
objectsandtools|tray.and.arrow.down|托盤 收件匣 箭頭 下 郵件
objectsandtools|tray.and.arrow.down.fill|托盤 收件匣 箭頭 下 郵件
objectsandtools|tray.and.arrow.up|托盤 收件匣 箭頭 上 郵件
objectsandtools|tray.and.arrow.up.fill|托盤 收件匣 箭頭 上 郵件
objectsandtools|tray.badge|托盤 收件匣 郵件
objectsandtools|tray.badge.fill|托盤 收件匣 郵件
objectsandtools|tray.circle|托盤 收件匣 圓形 郵件
objectsandtools|tray.circle.fill|托盤 收件匣 圓形 郵件
objectsandtools|tray.fill|托盤 收件匣 郵件
objectsandtools|tray.full|托盤 收件匣 郵件
objectsandtools|tray.full.fill|托盤 收件匣 郵件
objectsandtools|tshirt|
objectsandtools|tshirt.circle|圓形
objectsandtools|tshirt.circle.fill|圓形
objectsandtools|tshirt.fill|
objectsandtools|tuningfork|
objectsandtools|umbrella|雨傘
objectsandtools|umbrella.circle|雨傘 圓形
objectsandtools|umbrella.circle.fill|雨傘 圓形
objectsandtools|umbrella.fill|雨傘
objectsandtools|umbrella.percent|雨傘 百分比
objectsandtools|umbrella.percent.fill|雨傘 百分比
objectsandtools|wallet.bifold|錢包
objectsandtools|wallet.bifold.fill|錢包
objectsandtools|wallet.pass|錢包
objectsandtools|wallet.pass.fill|錢包
objectsandtools|watch.analog|手錶
objectsandtools|waterbottle|
objectsandtools|waterbottle.fill|
objectsandtools|waveform.path.ecg.magnifyingglass|放大鏡 搜尋
objectsandtools|wineglass|酒杯
objectsandtools|wineglass.fill|酒杯
objectsandtools|wrench.adjustable|扳手
objectsandtools|wrench.adjustable.fill|扳手
objectsandtools|wrench.and.screwdriver|扳手 螺絲起子
objectsandtools|wrench.and.screwdriver.fill|扳手 螺絲起子
objectsandtools|xmark.bin|叉 關閉 郵件
objectsandtools|xmark.bin.circle|叉 關閉 圓形 郵件
objectsandtools|xmark.bin.circle.fill|叉 關閉 圓形 郵件
objectsandtools|xmark.bin.fill|叉 關閉 郵件
objectsandtools|xmark.shield|叉 關閉 盾牌
objectsandtools|xmark.shield.fill|叉 關閉 盾牌
fitness|1.lane|
fitness|10.lane|
fitness|11.lane|
fitness|12.lane|
fitness|2.lane|
fitness|3.lane|
fitness|4.lane|
fitness|5.lane|
fitness|6.lane|
fitness|7.lane|
fitness|8.lane|
fitness|9.lane|
fitness|american.football|足球
fitness|american.football.circle|足球 圓形
fitness|american.football.circle.fill|足球 圓形
fitness|american.football.fill|足球
fitness|american.football.professional|足球
fitness|american.football.professional.circle|足球 圓形
fitness|american.football.professional.circle.fill|足球 圓形
fitness|american.football.professional.fill|足球
fitness|australian.football|足球
fitness|australian.football.circle|足球 圓形
fitness|australian.football.circle.fill|足球 圓形
fitness|australian.football.fill|足球
fitness|baseball|棒球
fitness|baseball.circle|棒球 圓形
fitness|baseball.circle.fill|棒球 圓形
fitness|baseball.diamond.bases|棒球
fitness|baseball.diamond.bases.outs.indicator|棒球
fitness|baseball.fill|棒球
fitness|basketball|籃球
fitness|basketball.circle|籃球 圓形
fitness|basketball.circle.fill|籃球 圓形
fitness|basketball.fill|籃球
fitness|cricket.ball|蟋蟀
fitness|cricket.ball.circle|蟋蟀 圓形
fitness|cricket.ball.circle.fill|蟋蟀 圓形
fitness|cricket.ball.fill|蟋蟀
fitness|duffle.bag|包包 袋
fitness|duffle.bag.fill|包包 袋
fitness|dumbbell|啞鈴
fitness|dumbbell.fill|啞鈴
fitness|figure.american.football|人形 足球 人 人物
fitness|figure.american.football.circle|人形 足球 圓形 人 人物
fitness|figure.american.football.circle.fill|人形 足球 圓形 人 人物
fitness|figure.archery|人形 人 人物
fitness|figure.archery.circle|人形 圓形 人 人物
fitness|figure.archery.circle.fill|人形 圓形 人 人物
fitness|figure.australian.football|人形 足球 人 人物
fitness|figure.australian.football.circle|人形 足球 圓形 人 人物
fitness|figure.australian.football.circle.fill|人形 足球 圓形 人 人物
fitness|figure.badminton|人形 羽毛球 人 人物
fitness|figure.badminton.circle|人形 羽毛球 圓形 人 人物
fitness|figure.badminton.circle.fill|人形 羽毛球 圓形 人 人物
fitness|figure.barre|人形 人 人物
fitness|figure.barre.circle|人形 圓形 人 人物
fitness|figure.barre.circle.fill|人形 圓形 人 人物
fitness|figure.baseball|人形 棒球 人 人物
fitness|figure.baseball.circle|人形 棒球 圓形 人 人物
fitness|figure.baseball.circle.fill|人形 棒球 圓形 人 人物
fitness|figure.basketball|人形 籃球 人 人物
fitness|figure.basketball.circle|人形 籃球 圓形 人 人物
fitness|figure.basketball.circle.fill|人形 籃球 圓形 人 人物
fitness|figure.bowling|人形 保齡球 人 人物
fitness|figure.bowling.circle|人形 保齡球 圓形 人 人物
fitness|figure.bowling.circle.fill|人形 保齡球 圓形 人 人物
fitness|figure.boxing|人形 人 人物
fitness|figure.boxing.circle|人形 圓形 人 人物
fitness|figure.boxing.circle.fill|人形 圓形 人 人物
fitness|figure.climbing|人形 人 人物
fitness|figure.climbing.circle|人形 圓形 人 人物
fitness|figure.climbing.circle.fill|人形 圓形 人 人物
fitness|figure.cooldown|人形 人 人物
fitness|figure.cooldown.circle|人形 圓形 人 人物
fitness|figure.cooldown.circle.fill|人形 圓形 人 人物
fitness|figure.core.training|人形 人 人物
fitness|figure.core.training.circle|人形 圓形 人 人物
fitness|figure.core.training.circle.fill|人形 圓形 人 人物
fitness|figure.cricket|人形 蟋蟀 人 人物
fitness|figure.cricket.circle|人形 蟋蟀 圓形 人 人物
fitness|figure.cricket.circle.fill|人形 蟋蟀 圓形 人 人物
fitness|figure.cross.training|人形 十字 人 人物
fitness|figure.cross.training.circle|人形 十字 圓形 人 人物
fitness|figure.cross.training.circle.fill|人形 十字 圓形 人 人物
fitness|figure.curling|人形 人 人物
fitness|figure.curling.circle|人形 圓形 人 人物
fitness|figure.curling.circle.fill|人形 圓形 人 人物
fitness|figure.dance|人形 人 人物
fitness|figure.dance.circle|人形 圓形 人 人物
fitness|figure.dance.circle.fill|人形 圓形 人 人物
fitness|figure.disc.sports|人形 人 人物
fitness|figure.disc.sports.circle|人形 圓形 人 人物
fitness|figure.disc.sports.circle.fill|人形 圓形 人 人物
fitness|figure.elliptical|人形 人 人物
fitness|figure.elliptical.circle|人形 圓形 人 人物
fitness|figure.elliptical.circle.fill|人形 圓形 人 人物
fitness|figure.equestrian.sports|人形 人 人物
fitness|figure.equestrian.sports.circle|人形 圓形 人 人物
fitness|figure.equestrian.sports.circle.fill|人形 圓形 人 人物
fitness|figure.fencing|人形 人 人物
fitness|figure.fencing.circle|人形 圓形 人 人物
fitness|figure.fencing.circle.fill|人形 圓形 人 人物
fitness|figure.field.hockey|人形 人 人物
fitness|figure.field.hockey.circle|人形 圓形 人 人物
fitness|figure.field.hockey.circle.fill|人形 圓形 人 人物
fitness|figure.fishing|人形 人 人物
fitness|figure.fishing.circle|人形 圓形 人 人物
fitness|figure.fishing.circle.fill|人形 圓形 人 人物
fitness|figure.flexibility|人形 人 人物
fitness|figure.flexibility.circle|人形 圓形 人 人物
fitness|figure.flexibility.circle.fill|人形 圓形 人 人物
fitness|figure.golf|人形 高爾夫 人 人物
fitness|figure.golf.circle|人形 高爾夫 圓形 人 人物
fitness|figure.golf.circle.fill|人形 高爾夫 圓形 人 人物
fitness|figure.gymnastics|人形 人 人物
fitness|figure.gymnastics.circle|人形 圓形 人 人物
fitness|figure.gymnastics.circle.fill|人形 圓形 人 人物
fitness|figure.hand.cycling|人形 手 人 人物
fitness|figure.hand.cycling.circle|人形 手 圓形 人 人物
fitness|figure.hand.cycling.circle.fill|人形 手 圓形 人 人物
fitness|figure.handball|人形 人 人物
fitness|figure.handball.circle|人形 圓形 人 人物
fitness|figure.handball.circle.fill|人形 圓形 人 人物
fitness|figure.highintensity.intervaltraining|人形 人 人物
fitness|figure.highintensity.intervaltraining.circle|人形 圓形 人 人物
fitness|figure.highintensity.intervaltraining.circle.fill|人形 圓形 人 人物
fitness|figure.hiking|人形 人 人物
fitness|figure.hiking.circle|人形 圓形 人 人物
fitness|figure.hiking.circle.fill|人形 圓形 人 人物
fitness|figure.hockey|人形 人 人物
fitness|figure.hockey.circle|人形 圓形 人 人物
fitness|figure.hockey.circle.fill|人形 圓形 人 人物
fitness|figure.hunting|人形 人 人物
fitness|figure.hunting.circle|人形 圓形 人 人物
fitness|figure.hunting.circle.fill|人形 圓形 人 人物
fitness|figure.ice.hockey|人形 冰塊 人 人物
fitness|figure.ice.hockey.circle|人形 冰塊 圓形 人 人物
fitness|figure.ice.hockey.circle.fill|人形 冰塊 圓形 人 人物
fitness|figure.ice.skating|人形 冰塊 人 人物
fitness|figure.ice.skating.circle|人形 冰塊 圓形 人 人物
fitness|figure.ice.skating.circle.fill|人形 冰塊 圓形 人 人物
fitness|figure.indoor.cycle|人形 人 人物
fitness|figure.indoor.cycle.circle|人形 圓形 人 人物
fitness|figure.indoor.cycle.circle.fill|人形 圓形 人 人物
fitness|figure.indoor.rowing|人形 人 人物
fitness|figure.indoor.rowing.circle|人形 圓形 人 人物
fitness|figure.indoor.rowing.circle.fill|人形 圓形 人 人物
fitness|figure.indoor.soccer|人形 人 人物
fitness|figure.indoor.soccer.circle|人形 圓形 人 人物
fitness|figure.indoor.soccer.circle.fill|人形 圓形 人 人物
fitness|figure.jumprope|人形 人 人物
fitness|figure.jumprope.circle|人形 圓形 人 人物
fitness|figure.jumprope.circle.fill|人形 圓形 人 人物
fitness|figure.kickboxing|人形 人 人物
fitness|figure.kickboxing.circle|人形 圓形 人 人物
fitness|figure.kickboxing.circle.fill|人形 圓形 人 人物
fitness|figure.lacrosse|人形 袋棍球 人 人物
fitness|figure.lacrosse.circle|人形 袋棍球 圓形 人 人物
fitness|figure.lacrosse.circle.fill|人形 袋棍球 圓形 人 人物
fitness|figure.martial.arts|人形 人 人物
fitness|figure.martial.arts.circle|人形 圓形 人 人物
fitness|figure.martial.arts.circle.fill|人形 圓形 人 人物
fitness|figure.mind.and.body|人形 人 人物
fitness|figure.mind.and.body.circle|人形 圓形 人 人物
fitness|figure.mind.and.body.circle.fill|人形 圓形 人 人物
fitness|figure.mixed.cardio|人形 人 人物
fitness|figure.mixed.cardio.circle|人形 圓形 人 人物
fitness|figure.mixed.cardio.circle.fill|人形 圓形 人 人物
fitness|figure.open.water.swim|人形 水 游泳 人 人物
fitness|figure.open.water.swim.circle|人形 水 游泳 圓形 人 人物
fitness|figure.open.water.swim.circle.fill|人形 水 游泳 圓形 人 人物
fitness|figure.outdoor.cycle|人形 腳踏車 單車 人 人物
fitness|figure.outdoor.cycle.circle|人形 圓形 腳踏車 單車 人 人物
fitness|figure.outdoor.cycle.circle.fill|人形 圓形 腳踏車 單車 人 人物
fitness|figure.outdoor.rowing|人形 人 人物
fitness|figure.outdoor.rowing.circle|人形 圓形 人 人物
fitness|figure.outdoor.rowing.circle.fill|人形 圓形 人 人物
fitness|figure.outdoor.soccer|人形 人 人物
fitness|figure.outdoor.soccer.circle|人形 圓形 人 人物
fitness|figure.outdoor.soccer.circle.fill|人形 圓形 人 人物
fitness|figure.pickleball|人形 人 人物
fitness|figure.pickleball.circle|人形 圓形 人 人物
fitness|figure.pickleball.circle.fill|人形 圓形 人 人物
fitness|figure.pilates|人形 人 人物
fitness|figure.pilates.circle|人形 圓形 人 人物
fitness|figure.pilates.circle.fill|人形 圓形 人 人物
fitness|figure.play|人形 播放 人 人物
fitness|figure.play.circle|人形 播放 圓形 人 人物
fitness|figure.play.circle.fill|人形 播放 圓形 人 人物
fitness|figure.pool.swim|人形 游泳 人 人物 水
fitness|figure.pool.swim.circle|人形 游泳 圓形 人 人物 水
fitness|figure.pool.swim.circle.fill|人形 游泳 圓形 人 人物 水
fitness|figure.racquetball|人形 人 人物
fitness|figure.racquetball.circle|人形 圓形 人 人物
fitness|figure.racquetball.circle.fill|人形 圓形 人 人物
fitness|figure.rolling|人形 人 人物
fitness|figure.rolling.circle|人形 圓形 人 人物
fitness|figure.rolling.circle.fill|人形 圓形 人 人物
fitness|figure.rugby|人形 人 人物
fitness|figure.rugby.circle|人形 圓形 人 人物
fitness|figure.rugby.circle.fill|人形 圓形 人 人物
fitness|figure.run|人形 跑步 人 人物
fitness|figure.run.circle|人形 跑步 圓形 人 人物
fitness|figure.run.circle.fill|人形 跑步 圓形 人 人物
fitness|figure.run.square.stack|人形 跑步 方形 人 人物
fitness|figure.run.square.stack.fill|人形 跑步 方形 人 人物
fitness|figure.run.treadmill|人形 跑步 人 人物
fitness|figure.run.treadmill.circle|人形 跑步 圓形 人 人物
fitness|figure.run.treadmill.circle.fill|人形 跑步 圓形 人 人物
fitness|figure.sailing|人形 人 人物
fitness|figure.sailing.circle|人形 圓形 人 人物
fitness|figure.sailing.circle.fill|人形 圓形 人 人物
fitness|figure.skateboarding|人形 人 人物
fitness|figure.skateboarding.circle|人形 圓形 人 人物
fitness|figure.skateboarding.circle.fill|人形 圓形 人 人物
fitness|figure.skiing.crosscountry|人形 人 人物
fitness|figure.skiing.crosscountry.circle|人形 圓形 人 人物
fitness|figure.skiing.crosscountry.circle.fill|人形 圓形 人 人物
fitness|figure.skiing.downhill|人形 人 人物
fitness|figure.skiing.downhill.circle|人形 圓形 人 人物
fitness|figure.skiing.downhill.circle.fill|人形 圓形 人 人物
fitness|figure.snowboarding|人形 人 人物
fitness|figure.snowboarding.circle|人形 圓形 人 人物
fitness|figure.snowboarding.circle.fill|人形 圓形 人 人物
fitness|figure.socialdance|人形 人 人物
fitness|figure.socialdance.circle|人形 圓形 人 人物
fitness|figure.socialdance.circle.fill|人形 圓形 人 人物
fitness|figure.softball|人形 壘球 人 人物
fitness|figure.softball.circle|人形 壘球 圓形 人 人物
fitness|figure.softball.circle.fill|人形 壘球 圓形 人 人物
fitness|figure.squash|人形 人 人物
fitness|figure.squash.circle|人形 圓形 人 人物
fitness|figure.squash.circle.fill|人形 圓形 人 人物
fitness|figure.stair.stepper|人形 人 人物
fitness|figure.stair.stepper.circle|人形 圓形 人 人物
fitness|figure.stair.stepper.circle.fill|人形 圓形 人 人物
fitness|figure.stairs|人形 人 人物
fitness|figure.stairs.circle|人形 圓形 人 人物
fitness|figure.stairs.circle.fill|人形 圓形 人 人物
fitness|figure.step.training|人形 人 人物
fitness|figure.step.training.circle|人形 圓形 人 人物
fitness|figure.step.training.circle.fill|人形 圓形 人 人物
fitness|figure.strengthtraining.functional|人形 人 人物
fitness|figure.strengthtraining.functional.circle|人形 圓形 人 人物
fitness|figure.strengthtraining.functional.circle.fill|人形 圓形 人 人物
fitness|figure.strengthtraining.traditional|人形 人 人物
fitness|figure.strengthtraining.traditional.circle|人形 圓形 人 人物
fitness|figure.strengthtraining.traditional.circle.fill|人形 圓形 人 人物
fitness|figure.surfing|人形 人 人物
fitness|figure.surfing.circle|人形 圓形 人 人物
fitness|figure.surfing.circle.fill|人形 圓形 人 人物
fitness|figure.table.tennis|人形 網球 人 人物
fitness|figure.table.tennis.circle|人形 網球 圓形 人 人物
fitness|figure.table.tennis.circle.fill|人形 網球 圓形 人 人物
fitness|figure.taichi|人形 人 人物
fitness|figure.taichi.circle|人形 圓形 人 人物
fitness|figure.taichi.circle.fill|人形 圓形 人 人物
fitness|figure.tennis|人形 網球 人 人物
fitness|figure.tennis.circle|人形 網球 圓形 人 人物
fitness|figure.tennis.circle.fill|人形 網球 圓形 人 人物
fitness|figure.track.and.field|人形 人 人物
fitness|figure.track.and.field.circle|人形 圓形 人 人物
fitness|figure.track.and.field.circle.fill|人形 圓形 人 人物
fitness|figure.volleyball|人形 排球 人 人物
fitness|figure.volleyball.circle|人形 排球 圓形 人 人物
fitness|figure.volleyball.circle.fill|人形 排球 圓形 人 人物
fitness|figure.walk|人形 走路 人 人物
fitness|figure.walk.circle|人形 走路 圓形 人 人物
fitness|figure.walk.circle.fill|人形 走路 圓形 人 人物
fitness|figure.walk.diamond|人形 走路 人 人物
fitness|figure.walk.diamond.fill|人形 走路 人 人物
fitness|figure.walk.motion|人形 走路 人 人物
fitness|figure.walk.motion.trianglebadge.exclamationmark|人形 走路 驚嘆號 警告 人 人物
fitness|figure.walk.treadmill|人形 走路 人 人物
fitness|figure.walk.treadmill.circle|人形 走路 圓形 人 人物
fitness|figure.walk.treadmill.circle.fill|人形 走路 圓形 人 人物
fitness|figure.water.fitness|人形 水 健身 人 人物
fitness|figure.water.fitness.circle|人形 水 健身 圓形 人 人物
fitness|figure.water.fitness.circle.fill|人形 水 健身 圓形 人 人物
fitness|figure.waterpolo|人形 人 人物 水
fitness|figure.waterpolo.circle|人形 圓形 人 人物 水
fitness|figure.waterpolo.circle.fill|人形 圓形 人 人物 水
fitness|figure.wrestling|人形 人 人物
fitness|figure.wrestling.circle|人形 圓形 人 人物
fitness|figure.wrestling.circle.fill|人形 圓形 人 人物
fitness|figure.yoga|人形 人 人物
fitness|figure.yoga.circle|人形 圓形 人 人物
fitness|figure.yoga.circle.fill|人形 圓形 人 人物
fitness|flag.2.crossed|旗幟 旗
fitness|flag.2.crossed.circle|旗幟 旗 圓形
fitness|flag.2.crossed.circle.fill|旗幟 旗 圓形
fitness|flag.2.crossed.fill|旗幟 旗
fitness|flag.and.flag.filled.crossed|旗幟 旗
fitness|flag.filled.and.flag.crossed|旗幟 旗
fitness|flag.pattern.checkered|旗幟 旗 露營
fitness|flag.pattern.checkered.2.crossed|旗幟 旗
fitness|flag.pattern.checkered.circle|旗幟 旗 圓形 露營
fitness|flag.pattern.checkered.circle.fill|旗幟 旗 圓形 露營
fitness|gauge.with.needle|健身 計時器
fitness|gauge.with.needle.fill|健身 計時器
fitness|hockey.puck|
fitness|hockey.puck.circle|圓形
fitness|hockey.puck.circle.fill|圓形
fitness|hockey.puck.fill|
fitness|lane|
fitness|medal|獎牌
fitness|medal.fill|獎牌
fitness|oar.2.crossed|
fitness|oar.2.crossed.circle|圓形
fitness|oar.2.crossed.circle.fill|圓形
fitness|rugbyball|
fitness|rugbyball.circle|圓形
fitness|rugbyball.circle.fill|圓形
fitness|rugbyball.fill|
fitness|shoe.running.and.shadow.fill|
fitness|skateboard|滑板
fitness|skateboard.fill|滑板
fitness|skis|滑雪
fitness|skis.fill|滑雪
fitness|snowboard|
fitness|snowboard.fill|
fitness|soccerball|足球
fitness|soccerball.circle|足球 圓形
fitness|soccerball.circle.fill|足球 圓形
fitness|soccerball.circle.fill.inverse|足球 圓形
fitness|soccerball.circle.inverse|足球 圓形
fitness|soccerball.inverse|足球
fitness|sportscourt|球場
fitness|sportscourt.circle|球場 圓形
fitness|sportscourt.circle.fill|球場 圓形
fitness|sportscourt.fill|球場
fitness|surfboard|
fitness|surfboard.fill|
fitness|tennis.racket|網球
fitness|tennis.racket.circle|網球 圓形
fitness|tennis.racket.circle.fill|網球 圓形
fitness|tennisball|
fitness|tennisball.circle|圓形
fitness|tennisball.circle.fill|圓形
fitness|tennisball.fill|
fitness|trophy|獎盃
fitness|trophy.circle|獎盃 圓形
fitness|trophy.circle.fill|獎盃 圓形
fitness|trophy.fill|獎盃
fitness|volleyball|排球
fitness|volleyball.circle|排球 圓形
fitness|volleyball.circle.fill|排球 圓形
fitness|volleyball.fill|排球
fitness|water.waves|水 波浪 游泳
fitness|water.waves.and.arrow.trianglehead.down|水 波浪 箭頭 下 游泳
fitness|water.waves.and.arrow.trianglehead.down.trianglebadge.exclamationmark|水 波浪 箭頭 下 驚嘆號 警告 游泳
fitness|water.waves.and.arrow.trianglehead.up|水 波浪 箭頭 上 游泳
fitness|water.waves.slash|水 波浪 正斜線 游泳
arrows|10.arrow.trianglehead.clockwise|箭頭
arrows|10.arrow.trianglehead.counterclockwise|箭頭
arrows|15.arrow.trianglehead.clockwise|箭頭
arrows|15.arrow.trianglehead.counterclockwise|箭頭
arrows|30.arrow.trianglehead.clockwise|箭頭
arrows|30.arrow.trianglehead.counterclockwise|箭頭
arrows|45.arrow.trianglehead.clockwise|箭頭
arrows|45.arrow.trianglehead.counterclockwise|箭頭
arrows|5.arrow.trianglehead.clockwise|箭頭
arrows|5.arrow.trianglehead.counterclockwise|箭頭
arrows|60.arrow.trianglehead.clockwise|箭頭
arrows|60.arrow.trianglehead.counterclockwise|箭頭
arrows|75.arrow.trianglehead.clockwise|箭頭
arrows|75.arrow.trianglehead.counterclockwise|箭頭
arrows|90.arrow.trianglehead.clockwise|箭頭
arrows|90.arrow.trianglehead.counterclockwise|箭頭
arrows|arrow.2.squarepath|箭頭
arrows|arrow.3.trianglepath|箭頭
arrows|arrow.backward|箭頭 倒轉 左
arrows|arrow.backward.circle|箭頭 倒轉 圓形 左
arrows|arrow.backward.circle.dotted|箭頭 倒轉 圓形 左
arrows|arrow.backward.circle.fill|箭頭 倒轉 圓形 左
arrows|arrow.backward.square|箭頭 倒轉 方形 左
arrows|arrow.backward.square.fill|箭頭 倒轉 方形 左
arrows|arrow.backward.to.line|箭頭 倒轉
arrows|arrow.backward.to.line.circle|箭頭 倒轉 圓形
arrows|arrow.backward.to.line.circle.fill|箭頭 倒轉 圓形
arrows|arrow.backward.to.line.compact|箭頭 倒轉
arrows|arrow.backward.to.line.square|箭頭 倒轉 方形
arrows|arrow.backward.to.line.square.fill|箭頭 倒轉 方形
arrows|arrow.clockwise|箭頭
arrows|arrow.clockwise.circle|箭頭 圓形
arrows|arrow.clockwise.circle.fill|箭頭 圓形
arrows|arrow.clockwise.square|箭頭 方形
arrows|arrow.clockwise.square.fill|箭頭 方形
arrows|arrow.counterclockwise|箭頭
arrows|arrow.counterclockwise.circle|箭頭 圓形
arrows|arrow.counterclockwise.circle.fill|箭頭 圓形
arrows|arrow.counterclockwise.square|箭頭 方形
arrows|arrow.counterclockwise.square.fill|箭頭 方形
arrows|arrow.down|箭頭 下
arrows|arrow.down.and.line.horizontal.and.arrow.up|箭頭 下 上
arrows|arrow.down.app|箭頭 下
arrows|arrow.down.app.fill|箭頭 下
arrows|arrow.down.backward|箭頭 下 倒轉 左
arrows|arrow.down.backward.and.arrow.up.forward|箭頭 下 倒轉 上 快轉
arrows|arrow.down.backward.and.arrow.up.forward.circle|箭頭 下 倒轉 上 快轉 圓形
arrows|arrow.down.backward.and.arrow.up.forward.circle.fill|箭頭 下 倒轉 上 快轉 圓形
arrows|arrow.down.backward.and.arrow.up.forward.rectangle|箭頭 下 倒轉 上 快轉 長方形
arrows|arrow.down.backward.and.arrow.up.forward.rectangle.fill|箭頭 下 倒轉 上 快轉 長方形
arrows|arrow.down.backward.and.arrow.up.forward.square|箭頭 下 倒轉 上 快轉 方形
arrows|arrow.down.backward.and.arrow.up.forward.square.fill|箭頭 下 倒轉 上 快轉 方形
arrows|arrow.down.backward.circle|箭頭 下 倒轉 圓形 左
arrows|arrow.down.backward.circle.dotted|箭頭 下 倒轉 圓形 左
arrows|arrow.down.backward.circle.fill|箭頭 下 倒轉 圓形 左
arrows|arrow.down.backward.square|箭頭 下 倒轉 方形 左
arrows|arrow.down.backward.square.fill|箭頭 下 倒轉 方形 左
arrows|arrow.down.backward.toptrailing.rectangle|箭頭 下 倒轉 長方形
arrows|arrow.down.backward.toptrailing.rectangle.fill|箭頭 下 倒轉 長方形
arrows|arrow.down.circle|箭頭 下 圓形
arrows|arrow.down.circle.badge.pause|箭頭 下 圓形 暫停
arrows|arrow.down.circle.badge.pause.fill|箭頭 下 圓形 暫停
arrows|arrow.down.circle.badge.xmark|箭頭 下 圓形 叉 關閉
arrows|arrow.down.circle.badge.xmark.fill|箭頭 下 圓形 叉 關閉
arrows|arrow.down.circle.dotted|箭頭 下 圓形
arrows|arrow.down.circle.fill|箭頭 下 圓形
arrows|arrow.down.forward|箭頭 下 快轉 右
arrows|arrow.down.forward.and.arrow.up.backward|箭頭 下 快轉 上 倒轉
arrows|arrow.down.forward.and.arrow.up.backward.circle|箭頭 下 快轉 上 倒轉 圓形
arrows|arrow.down.forward.and.arrow.up.backward.circle.fill|箭頭 下 快轉 上 倒轉 圓形
arrows|arrow.down.forward.and.arrow.up.backward.rectangle|箭頭 下 快轉 上 倒轉 長方形
arrows|arrow.down.forward.and.arrow.up.backward.rectangle.fill|箭頭 下 快轉 上 倒轉 長方形
arrows|arrow.down.forward.and.arrow.up.backward.square|箭頭 下 快轉 上 倒轉 方形
arrows|arrow.down.forward.and.arrow.up.backward.square.fill|箭頭 下 快轉 上 倒轉 方形
arrows|arrow.down.forward.circle|箭頭 下 快轉 圓形 右
arrows|arrow.down.forward.circle.dotted|箭頭 下 快轉 圓形 右
arrows|arrow.down.forward.circle.fill|箭頭 下 快轉 圓形 右
arrows|arrow.down.forward.square|箭頭 下 快轉 方形 右
arrows|arrow.down.forward.square.fill|箭頭 下 快轉 方形 右
arrows|arrow.down.forward.topleading.rectangle|箭頭 下 快轉 長方形
arrows|arrow.down.forward.topleading.rectangle.fill|箭頭 下 快轉 長方形
arrows|arrow.down.heart|箭頭 下 愛心 心
arrows|arrow.down.heart.fill|箭頭 下 愛心 心
arrows|arrow.down.left|箭頭 下 左
arrows|arrow.down.left.and.arrow.up.right|箭頭 下 左 上 右
arrows|arrow.down.left.and.arrow.up.right.circle|箭頭 下 左 上 右 圓形
arrows|arrow.down.left.and.arrow.up.right.circle.fill|箭頭 下 左 上 右 圓形
arrows|arrow.down.left.and.arrow.up.right.rectangle|箭頭 下 左 上 右 長方形
arrows|arrow.down.left.and.arrow.up.right.rectangle.fill|箭頭 下 左 上 右 長方形
arrows|arrow.down.left.and.arrow.up.right.square|箭頭 下 左 上 右 方形
arrows|arrow.down.left.and.arrow.up.right.square.fill|箭頭 下 左 上 右 方形
arrows|arrow.down.left.arrow.up.right|箭頭 下 左 上 右
arrows|arrow.down.left.arrow.up.right.circle|箭頭 下 左 上 右 圓形
arrows|arrow.down.left.arrow.up.right.circle.fill|箭頭 下 左 上 右 圓形
arrows|arrow.down.left.arrow.up.right.square|箭頭 下 左 上 右 方形
arrows|arrow.down.left.arrow.up.right.square.fill|箭頭 下 左 上 右 方形
arrows|arrow.down.left.circle|箭頭 下 左 圓形
arrows|arrow.down.left.circle.dotted|箭頭 下 左 圓形
arrows|arrow.down.left.circle.fill|箭頭 下 左 圓形
arrows|arrow.down.left.square|箭頭 下 左 方形
arrows|arrow.down.left.square.fill|箭頭 下 左 方形
arrows|arrow.down.left.topright.rectangle|箭頭 下 左 長方形
arrows|arrow.down.left.topright.rectangle.fill|箭頭 下 左 長方形
arrows|arrow.down.right|箭頭 下 右
arrows|arrow.down.right.and.arrow.up.left|箭頭 下 右 上 左
arrows|arrow.down.right.and.arrow.up.left.circle|箭頭 下 右 上 左 圓形
arrows|arrow.down.right.and.arrow.up.left.circle.fill|箭頭 下 右 上 左 圓形
arrows|arrow.down.right.and.arrow.up.left.rectangle|箭頭 下 右 上 左 長方形
arrows|arrow.down.right.and.arrow.up.left.rectangle.fill|箭頭 下 右 上 左 長方形
arrows|arrow.down.right.and.arrow.up.left.square|箭頭 下 右 上 左 方形
arrows|arrow.down.right.and.arrow.up.left.square.fill|箭頭 下 右 上 左 方形
arrows|arrow.down.right.circle|箭頭 下 右 圓形
arrows|arrow.down.right.circle.dotted|箭頭 下 右 圓形
arrows|arrow.down.right.circle.fill|箭頭 下 右 圓形
arrows|arrow.down.right.square|箭頭 下 右 方形
arrows|arrow.down.right.square.fill|箭頭 下 右 方形
arrows|arrow.down.right.topleft.rectangle|箭頭 下 右 長方形
arrows|arrow.down.right.topleft.rectangle.fill|箭頭 下 右 長方形
arrows|arrow.down.square|箭頭 下 方形
arrows|arrow.down.square.fill|箭頭 下 方形
arrows|arrow.down.to.line|箭頭 下
arrows|arrow.down.to.line.circle|箭頭 下 圓形
arrows|arrow.down.to.line.circle.fill|箭頭 下 圓形
arrows|arrow.down.to.line.compact|箭頭 下
arrows|arrow.down.to.line.square|箭頭 下 方形
arrows|arrow.down.to.line.square.fill|箭頭 下 方形
arrows|arrow.forward|箭頭 快轉 右
arrows|arrow.forward.circle|箭頭 快轉 圓形 右
arrows|arrow.forward.circle.dotted|箭頭 快轉 圓形 右
arrows|arrow.forward.circle.fill|箭頭 快轉 圓形 右
arrows|arrow.forward.square|箭頭 快轉 方形 右
arrows|arrow.forward.square.fill|箭頭 快轉 方形 右
arrows|arrow.forward.to.line|箭頭 快轉
arrows|arrow.forward.to.line.circle|箭頭 快轉 圓形
arrows|arrow.forward.to.line.circle.fill|箭頭 快轉 圓形
arrows|arrow.forward.to.line.compact|箭頭 快轉
arrows|arrow.forward.to.line.square|箭頭 快轉 方形
arrows|arrow.forward.to.line.square.fill|箭頭 快轉 方形
arrows|arrow.left|箭頭 左
arrows|arrow.left.and.line.vertical.and.arrow.right|箭頭 左 右
arrows|arrow.left.and.right|箭頭 左 右
arrows|arrow.left.and.right.circle|箭頭 左 右 圓形
arrows|arrow.left.and.right.circle.fill|箭頭 左 右 圓形
arrows|arrow.left.and.right.square|箭頭 左 右 方形
arrows|arrow.left.and.right.square.fill|箭頭 左 右 方形
arrows|arrow.left.arrow.right|箭頭 左 右
arrows|arrow.left.arrow.right.circle|箭頭 左 右 圓形
arrows|arrow.left.arrow.right.circle.fill|箭頭 左 右 圓形
arrows|arrow.left.arrow.right.square|箭頭 左 右 方形
arrows|arrow.left.arrow.right.square.fill|箭頭 左 右 方形
arrows|arrow.left.circle|箭頭 左 圓形
arrows|arrow.left.circle.dotted|箭頭 左 圓形
arrows|arrow.left.circle.fill|箭頭 左 圓形
arrows|arrow.left.square|箭頭 左 方形
arrows|arrow.left.square.fill|箭頭 左 方形
arrows|arrow.left.to.line|箭頭 左
arrows|arrow.left.to.line.circle|箭頭 左 圓形
arrows|arrow.left.to.line.circle.fill|箭頭 左 圓形
arrows|arrow.left.to.line.compact|箭頭 左
arrows|arrow.left.to.line.square|箭頭 左 方形
arrows|arrow.left.to.line.square.fill|箭頭 左 方形
arrows|arrow.right|箭頭 右
arrows|arrow.right.and.line.vertical.and.arrow.left|箭頭 右 左
arrows|arrow.right.circle|箭頭 右 圓形
arrows|arrow.right.circle.dotted|箭頭 右 圓形
arrows|arrow.right.circle.fill|箭頭 右 圓形
arrows|arrow.right.square|箭頭 右 方形
arrows|arrow.right.square.fill|箭頭 右 方形
arrows|arrow.right.to.line|箭頭 右
arrows|arrow.right.to.line.circle|箭頭 右 圓形
arrows|arrow.right.to.line.circle.fill|箭頭 右 圓形
arrows|arrow.right.to.line.compact|箭頭 右
arrows|arrow.right.to.line.square|箭頭 右 方形
arrows|arrow.right.to.line.square.fill|箭頭 右 方形
arrows|arrow.trianglehead.2.clockwise|箭頭
arrows|arrow.trianglehead.2.clockwise.rotate.90|箭頭
arrows|arrow.trianglehead.2.clockwise.rotate.90.circle|箭頭 圓形
arrows|arrow.trianglehead.2.clockwise.rotate.90.circle.fill|箭頭 圓形
arrows|arrow.trianglehead.2.counterclockwise|箭頭
arrows|arrow.trianglehead.2.counterclockwise.rotate.90|箭頭
arrows|arrow.trianglehead.bottomleft.capsulepath.clockwise|箭頭
arrows|arrow.trianglehead.branch|箭頭
arrows|arrow.trianglehead.clockwise|箭頭
arrows|arrow.trianglehead.clockwise.heart|箭頭 愛心 心
arrows|arrow.trianglehead.clockwise.heart.fill|箭頭 愛心 心
arrows|arrow.trianglehead.clockwise.rotate.90|箭頭 警告
arrows|arrow.trianglehead.counterclockwise|箭頭
arrows|arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|arrow.trianglehead.merge|箭頭
arrows|arrow.trianglehead.pull|箭頭
arrows|arrow.trianglehead.swap|箭頭
arrows|arrow.trianglehead.topright.capsulepath.clockwise|箭頭
arrows|arrow.trianglehead.turn.up.right|箭頭 上 右
arrows|arrow.trianglehead.turn.up.right.circle|箭頭 上 右 圓形
arrows|arrow.trianglehead.turn.up.right.circle.fill|箭頭 上 右 圓形
arrows|arrow.trianglehead.turn.up.right.diamond|箭頭 上 右
arrows|arrow.trianglehead.turn.up.right.diamond.fill|箭頭 上 右
arrows|arrow.turn.down.left|箭頭 下 左
arrows|arrow.turn.down.right|箭頭 下 右
arrows|arrow.turn.left.down|箭頭 左 下
arrows|arrow.turn.left.up|箭頭 左 上
arrows|arrow.turn.right.down|箭頭 右 下
arrows|arrow.turn.right.up|箭頭 右 上
arrows|arrow.turn.up.left|箭頭 上 左
arrows|arrow.turn.up.right|箭頭 上 右
arrows|arrow.up|箭頭 上
arrows|arrow.up.and.down|箭頭 上 下
arrows|arrow.up.and.down.circle|箭頭 上 下 圓形
arrows|arrow.up.and.down.circle.fill|箭頭 上 下 圓形
arrows|arrow.up.and.down.square|箭頭 上 下 方形
arrows|arrow.up.and.down.square.fill|箭頭 上 下 方形
arrows|arrow.up.and.line.horizontal.and.arrow.down|箭頭 上 下
arrows|arrow.up.arrow.down|箭頭 上 下
arrows|arrow.up.arrow.down.circle|箭頭 上 下 圓形
arrows|arrow.up.arrow.down.circle.fill|箭頭 上 下 圓形
arrows|arrow.up.arrow.down.square|箭頭 上 下 方形
arrows|arrow.up.arrow.down.square.fill|箭頭 上 下 方形
arrows|arrow.up.backward|箭頭 上 倒轉 左
arrows|arrow.up.backward.and.arrow.down.forward|箭頭 上 倒轉 下 快轉
arrows|arrow.up.backward.and.arrow.down.forward.circle|箭頭 上 倒轉 下 快轉 圓形
arrows|arrow.up.backward.and.arrow.down.forward.circle.fill|箭頭 上 倒轉 下 快轉 圓形
arrows|arrow.up.backward.and.arrow.down.forward.rectangle|箭頭 上 倒轉 下 快轉 長方形
arrows|arrow.up.backward.and.arrow.down.forward.rectangle.fill|箭頭 上 倒轉 下 快轉 長方形
arrows|arrow.up.backward.and.arrow.down.forward.square|箭頭 上 倒轉 下 快轉 方形
arrows|arrow.up.backward.and.arrow.down.forward.square.fill|箭頭 上 倒轉 下 快轉 方形
arrows|arrow.up.backward.bottomtrailing.rectangle|箭頭 上 倒轉 長方形
arrows|arrow.up.backward.bottomtrailing.rectangle.fill|箭頭 上 倒轉 長方形
arrows|arrow.up.backward.circle|箭頭 上 倒轉 圓形 左
arrows|arrow.up.backward.circle.dotted|箭頭 上 倒轉 圓形 左
arrows|arrow.up.backward.circle.fill|箭頭 上 倒轉 圓形 左
arrows|arrow.up.backward.square|箭頭 上 倒轉 方形 左
arrows|arrow.up.backward.square.fill|箭頭 上 倒轉 方形 左
arrows|arrow.up.circle|箭頭 上 圓形
arrows|arrow.up.circle.badge.clock|箭頭 上 圓形 時鐘 時間
arrows|arrow.up.circle.dotted|箭頭 上 圓形
arrows|arrow.up.circle.fill|箭頭 上 圓形
arrows|arrow.up.forward|箭頭 上 快轉 右
arrows|arrow.up.forward.and.arrow.down.backward|箭頭 上 快轉 下 倒轉
arrows|arrow.up.forward.and.arrow.down.backward.circle|箭頭 上 快轉 下 倒轉 圓形
arrows|arrow.up.forward.and.arrow.down.backward.circle.fill|箭頭 上 快轉 下 倒轉 圓形
arrows|arrow.up.forward.and.arrow.down.backward.rectangle|箭頭 上 快轉 下 倒轉 長方形
arrows|arrow.up.forward.and.arrow.down.backward.rectangle.fill|箭頭 上 快轉 下 倒轉 長方形
arrows|arrow.up.forward.and.arrow.down.backward.square|箭頭 上 快轉 下 倒轉 方形
arrows|arrow.up.forward.and.arrow.down.backward.square.fill|箭頭 上 快轉 下 倒轉 方形
arrows|arrow.up.forward.app|箭頭 上 快轉
arrows|arrow.up.forward.app.fill|箭頭 上 快轉
arrows|arrow.up.forward.bottomleading.rectangle|箭頭 上 快轉 長方形
arrows|arrow.up.forward.bottomleading.rectangle.fill|箭頭 上 快轉 長方形
arrows|arrow.up.forward.circle|箭頭 上 快轉 圓形 右
arrows|arrow.up.forward.circle.dotted|箭頭 上 快轉 圓形 右
arrows|arrow.up.forward.circle.fill|箭頭 上 快轉 圓形 右
arrows|arrow.up.forward.square|箭頭 上 快轉 方形 右
arrows|arrow.up.forward.square.fill|箭頭 上 快轉 方形 右
arrows|arrow.up.heart|箭頭 上 愛心 心
arrows|arrow.up.heart.fill|箭頭 上 愛心 心
arrows|arrow.up.left|箭頭 上 左
arrows|arrow.up.left.and.arrow.down.right|箭頭 上 左 下 右
arrows|arrow.up.left.and.arrow.down.right.circle|箭頭 上 左 下 右 圓形
arrows|arrow.up.left.and.arrow.down.right.circle.fill|箭頭 上 左 下 右 圓形
arrows|arrow.up.left.and.arrow.down.right.rectangle|箭頭 上 左 下 右 長方形
arrows|arrow.up.left.and.arrow.down.right.rectangle.fill|箭頭 上 左 下 右 長方形
arrows|arrow.up.left.and.arrow.down.right.square|箭頭 上 左 下 右 方形
arrows|arrow.up.left.and.arrow.down.right.square.fill|箭頭 上 左 下 右 方形
arrows|arrow.up.left.arrow.down.right|箭頭 上 左 下 右
arrows|arrow.up.left.arrow.down.right.circle|箭頭 上 左 下 右 圓形
arrows|arrow.up.left.arrow.down.right.circle.fill|箭頭 上 左 下 右 圓形
arrows|arrow.up.left.arrow.down.right.square|箭頭 上 左 下 右 方形
arrows|arrow.up.left.arrow.down.right.square.fill|箭頭 上 左 下 右 方形
arrows|arrow.up.left.bottomright.rectangle|箭頭 上 左 長方形
arrows|arrow.up.left.bottomright.rectangle.fill|箭頭 上 左 長方形
arrows|arrow.up.left.circle|箭頭 上 左 圓形
arrows|arrow.up.left.circle.dotted|箭頭 上 左 圓形
arrows|arrow.up.left.circle.fill|箭頭 上 左 圓形
arrows|arrow.up.left.square|箭頭 上 左 方形
arrows|arrow.up.left.square.fill|箭頭 上 左 方形
arrows|arrow.up.right|箭頭 上 右
arrows|arrow.up.right.and.arrow.down.left|箭頭 上 右 下 左
arrows|arrow.up.right.and.arrow.down.left.circle|箭頭 上 右 下 左 圓形
arrows|arrow.up.right.and.arrow.down.left.circle.fill|箭頭 上 右 下 左 圓形
arrows|arrow.up.right.and.arrow.down.left.rectangle|箭頭 上 右 下 左 長方形
arrows|arrow.up.right.and.arrow.down.left.rectangle.fill|箭頭 上 右 下 左 長方形
arrows|arrow.up.right.and.arrow.down.left.square|箭頭 上 右 下 左 方形
arrows|arrow.up.right.and.arrow.down.left.square.fill|箭頭 上 右 下 左 方形
arrows|arrow.up.right.bottomleft.rectangle|箭頭 上 右 長方形
arrows|arrow.up.right.bottomleft.rectangle.fill|箭頭 上 右 長方形
arrows|arrow.up.right.circle|箭頭 上 右 圓形
arrows|arrow.up.right.circle.dotted|箭頭 上 右 圓形
arrows|arrow.up.right.circle.fill|箭頭 上 右 圓形
arrows|arrow.up.right.square|箭頭 上 右 方形
arrows|arrow.up.right.square.fill|箭頭 上 右 方形
arrows|arrow.up.square|箭頭 上 方形
arrows|arrow.up.square.fill|箭頭 上 方形
arrows|arrow.up.to.line|箭頭 上 家
arrows|arrow.up.to.line.circle|箭頭 上 圓形
arrows|arrow.up.to.line.circle.fill|箭頭 上 圓形
arrows|arrow.up.to.line.compact|箭頭 上 家
arrows|arrow.up.to.line.square|箭頭 上 方形
arrows|arrow.up.to.line.square.fill|箭頭 上 方形
arrows|arrow.uturn.backward|箭頭 倒轉 左
arrows|arrow.uturn.backward.circle|箭頭 倒轉 圓形 左
arrows|arrow.uturn.backward.circle.badge.ellipsis|箭頭 倒轉 圓形 省略號 左
arrows|arrow.uturn.backward.circle.fill|箭頭 倒轉 圓形 左
arrows|arrow.uturn.backward.square|箭頭 倒轉 方形 左
arrows|arrow.uturn.backward.square.fill|箭頭 倒轉 方形 左
arrows|arrow.uturn.down|箭頭 下
arrows|arrow.uturn.down.circle|箭頭 下 圓形
arrows|arrow.uturn.down.circle.fill|箭頭 下 圓形
arrows|arrow.uturn.down.square|箭頭 下 方形
arrows|arrow.uturn.down.square.fill|箭頭 下 方形
arrows|arrow.uturn.forward|箭頭 快轉 右
arrows|arrow.uturn.forward.circle|箭頭 快轉 圓形 右
arrows|arrow.uturn.forward.circle.fill|箭頭 快轉 圓形 右
arrows|arrow.uturn.forward.square|箭頭 快轉 方形 右
arrows|arrow.uturn.forward.square.fill|箭頭 快轉 方形 右
arrows|arrow.uturn.left|箭頭 左
arrows|arrow.uturn.left.circle|箭頭 左 圓形
arrows|arrow.uturn.left.circle.badge.ellipsis|箭頭 左 圓形 省略號
arrows|arrow.uturn.left.circle.fill|箭頭 左 圓形
arrows|arrow.uturn.left.square|箭頭 左 方形
arrows|arrow.uturn.left.square.fill|箭頭 左 方形
arrows|arrow.uturn.right|箭頭 右
arrows|arrow.uturn.right.circle|箭頭 右 圓形
arrows|arrow.uturn.right.circle.fill|箭頭 右 圓形
arrows|arrow.uturn.right.square|箭頭 右 方形
arrows|arrow.uturn.right.square.fill|箭頭 右 方形
arrows|arrow.uturn.up|箭頭 上
arrows|arrow.uturn.up.circle|箭頭 上 圓形
arrows|arrow.uturn.up.circle.fill|箭頭 上 圓形
arrows|arrow.uturn.up.square|箭頭 上 方形
arrows|arrow.uturn.up.square.fill|箭頭 上 方形
arrows|arrowshape.backward|倒轉
arrows|arrowshape.backward.circle|倒轉 圓形
arrows|arrowshape.backward.circle.fill|倒轉 圓形
arrows|arrowshape.backward.fill|倒轉
arrows|arrowshape.bounce.forward|快轉
arrows|arrowshape.bounce.forward.fill|快轉
arrows|arrowshape.bounce.right|右 郵件
arrows|arrowshape.bounce.right.fill|右 郵件
arrows|arrowshape.down|下
arrows|arrowshape.down.circle|下 圓形
arrows|arrowshape.down.circle.fill|下 圓形
arrows|arrowshape.down.fill|下
arrows|arrowshape.forward|快轉
arrows|arrowshape.forward.circle|快轉 圓形
arrows|arrowshape.forward.circle.fill|快轉 圓形
arrows|arrowshape.forward.fill|快轉
arrows|arrowshape.left|左
arrows|arrowshape.left.arrowshape.right|左 右
arrows|arrowshape.left.arrowshape.right.fill|左 右
arrows|arrowshape.left.circle|左 圓形
arrows|arrowshape.left.circle.fill|左 圓形
arrows|arrowshape.left.fill|左
arrows|arrowshape.right|右
arrows|arrowshape.right.circle|右 圓形
arrows|arrowshape.right.circle.fill|右 圓形
arrows|arrowshape.right.fill|右
arrows|arrowshape.turn.up.backward|上 倒轉
arrows|arrowshape.turn.up.backward.2|上 倒轉
arrows|arrowshape.turn.up.backward.2.circle|上 倒轉 圓形
arrows|arrowshape.turn.up.backward.2.circle.fill|上 倒轉 圓形
arrows|arrowshape.turn.up.backward.2.fill|上 倒轉
arrows|arrowshape.turn.up.backward.badge.clock|上 倒轉 時鐘 時間
arrows|arrowshape.turn.up.backward.badge.clock.fill|上 倒轉 時鐘 時間
arrows|arrowshape.turn.up.backward.circle|上 倒轉 圓形
arrows|arrowshape.turn.up.backward.circle.fill|上 倒轉 圓形
arrows|arrowshape.turn.up.backward.fill|上 倒轉
arrows|arrowshape.turn.up.forward|上 快轉
arrows|arrowshape.turn.up.forward.circle|上 快轉 圓形
arrows|arrowshape.turn.up.forward.circle.fill|上 快轉 圓形
arrows|arrowshape.turn.up.forward.fill|上 快轉
arrows|arrowshape.turn.up.left|上 左 郵件
arrows|arrowshape.turn.up.left.2|上 左 郵件
arrows|arrowshape.turn.up.left.2.circle|上 左 圓形
arrows|arrowshape.turn.up.left.2.circle.fill|上 左 圓形
arrows|arrowshape.turn.up.left.2.fill|上 左 郵件
arrows|arrowshape.turn.up.left.circle|上 左 圓形
arrows|arrowshape.turn.up.left.circle.fill|上 左 圓形
arrows|arrowshape.turn.up.left.fill|上 左 郵件
arrows|arrowshape.turn.up.right|上 右 快轉 郵件
arrows|arrowshape.turn.up.right.circle|上 右 圓形 快轉
arrows|arrowshape.turn.up.right.circle.fill|上 右 圓形 快轉
arrows|arrowshape.turn.up.right.fill|上 右 快轉 郵件
arrows|arrowshape.up|上
arrows|arrowshape.up.circle|上 圓形
arrows|arrowshape.up.circle.fill|上 圓形
arrows|arrowshape.up.fill|上
arrows|arrowshape.zigzag.forward|快轉
arrows|arrowshape.zigzag.forward.fill|快轉
arrows|arrowshape.zigzag.right|右 郵件
arrows|arrowshape.zigzag.right.fill|右 郵件
arrows|arrowtriangle.backward|倒轉 左
arrows|arrowtriangle.backward.circle|倒轉 圓形 左
arrows|arrowtriangle.backward.circle.fill|倒轉 圓形 左
arrows|arrowtriangle.backward.fill|倒轉 左
arrows|arrowtriangle.backward.square|倒轉 方形 左
arrows|arrowtriangle.backward.square.fill|倒轉 方形 左
arrows|arrowtriangle.down|下
arrows|arrowtriangle.down.2|下
arrows|arrowtriangle.down.2.fill|下
arrows|arrowtriangle.down.circle|下 圓形
arrows|arrowtriangle.down.circle.fill|下 圓形
arrows|arrowtriangle.down.fill|下
arrows|arrowtriangle.down.square|下 方形
arrows|arrowtriangle.down.square.fill|下 方形
arrows|arrowtriangle.forward|快轉 右
arrows|arrowtriangle.forward.circle|快轉 圓形 右
arrows|arrowtriangle.forward.circle.fill|快轉 圓形 右
arrows|arrowtriangle.forward.fill|快轉 右
arrows|arrowtriangle.forward.square|快轉 方形 右
arrows|arrowtriangle.forward.square.fill|快轉 方形 右
arrows|arrowtriangle.left|左
arrows|arrowtriangle.left.and.line.vertical.and.arrowtriangle.right|左 右
arrows|arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill|左 右
arrows|arrowtriangle.left.circle|左 圓形
arrows|arrowtriangle.left.circle.fill|左 圓形
arrows|arrowtriangle.left.fill|左
arrows|arrowtriangle.left.square|左 方形
arrows|arrowtriangle.left.square.fill|左 方形
arrows|arrowtriangle.right|右
arrows|arrowtriangle.right.and.line.vertical.and.arrowtriangle.left|右 左
arrows|arrowtriangle.right.and.line.vertical.and.arrowtriangle.left.fill|右 左
arrows|arrowtriangle.right.circle|右 圓形
arrows|arrowtriangle.right.circle.fill|右 圓形
arrows|arrowtriangle.right.fill|右
arrows|arrowtriangle.right.square|右 方形
arrows|arrowtriangle.right.square.fill|右 方形
arrows|arrowtriangle.up|上
arrows|arrowtriangle.up.2|上
arrows|arrowtriangle.up.2.fill|上
arrows|arrowtriangle.up.circle|上 圓形
arrows|arrowtriangle.up.circle.fill|上 圓形
arrows|arrowtriangle.up.fill|上
arrows|arrowtriangle.up.square|上 方形
arrows|arrowtriangle.up.square.fill|上 方形
arrows|australiandollarsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|australsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|bahtsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|bitcoinsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|brazilianrealsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|cedisign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|centsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|checkmark.arrow.trianglehead.counterclockwise|勾 勾選 箭頭
arrows|chevron.backward|倒轉 左
arrows|chevron.backward.2|倒轉 左
arrows|chevron.backward.chevron.backward.dotted|倒轉 左
arrows|chevron.backward.circle|倒轉 圓形 左
arrows|chevron.backward.circle.fill|倒轉 圓形 左
arrows|chevron.backward.square|倒轉 方形 左
arrows|chevron.backward.square.fill|倒轉 方形 左
arrows|chevron.compact.backward|倒轉
arrows|chevron.compact.down|下
arrows|chevron.compact.forward|快轉
arrows|chevron.compact.left|左
arrows|chevron.compact.left.chevron.compact.right|左 右
arrows|chevron.compact.right|右
arrows|chevron.compact.up|上
arrows|chevron.compact.up.chevron.compact.down|上 下
arrows|chevron.compact.up.chevron.compact.right.chevron.compact.down.chevron.compact.left|上 右 下 左
arrows|chevron.down|下
arrows|chevron.down.2|下
arrows|chevron.down.circle|下 圓形
arrows|chevron.down.circle.fill|下 圓形
arrows|chevron.down.dotted.2|下
arrows|chevron.down.forward.2|下 快轉
arrows|chevron.down.forward.dotted.2|下 快轉
arrows|chevron.down.right.2|下 右
arrows|chevron.down.right.dotted.2|下 右
arrows|chevron.down.square|下 方形
arrows|chevron.down.square.fill|下 方形
arrows|chevron.forward|快轉 右
arrows|chevron.forward.2|快轉 右
arrows|chevron.forward.circle|快轉 圓形 右
arrows|chevron.forward.circle.fill|快轉 圓形 右
arrows|chevron.forward.dotted.chevron.forward|快轉 右
arrows|chevron.forward.square|快轉 方形 右
arrows|chevron.forward.square.fill|快轉 方形 右
arrows|chevron.left|左
arrows|chevron.left.2|左
arrows|chevron.left.chevron.left.dotted|左
arrows|chevron.left.chevron.right|左 右
arrows|chevron.left.circle|左 圓形
arrows|chevron.left.circle.fill|左 圓形
arrows|chevron.left.square|左 方形
arrows|chevron.left.square.fill|左 方形
arrows|chevron.right|右
arrows|chevron.right.2|右
arrows|chevron.right.circle|右 圓形
arrows|chevron.right.circle.fill|右 圓形
arrows|chevron.right.dotted.chevron.right|右
arrows|chevron.right.square|右 方形
arrows|chevron.right.square.fill|右 方形
arrows|chevron.up|上
arrows|chevron.up.2|上
arrows|chevron.up.chevron.down|上 下
arrows|chevron.up.chevron.down.square|上 下 方形
arrows|chevron.up.chevron.down.square.fill|上 下 方形
arrows|chevron.up.chevron.right.chevron.down.chevron.left|上 右 下 左
arrows|chevron.up.circle|上 圓形
arrows|chevron.up.circle.fill|上 圓形
arrows|chevron.up.dotted.2|上
arrows|chevron.up.forward.2|上 快轉
arrows|chevron.up.forward.dotted.2|上 快轉
arrows|chevron.up.right.2|上 右
arrows|chevron.up.right.dotted.2|上 右
arrows|chevron.up.square|上 方形
arrows|chevron.up.square.fill|上 方形
arrows|chineseyuanrenminbisign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|clock.arrow.trianglehead.2.counterclockwise.rotate.90|時鐘 時間 箭頭
arrows|clock.arrow.trianglehead.counterclockwise.rotate.90|時鐘 時間 箭頭
arrows|coloncurrencysign.arrow.trianglehead.counterclockwise.rotate.90|貨幣 箭頭
arrows|cruzeirosign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|danishkronesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|dollarsign.arrow.trianglehead.counterclockwise.rotate.90|美元 箭頭
arrows|dongsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|eurosign.arrow.trianglehead.counterclockwise.rotate.90|歐元 箭頭
arrows|eurozonesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|exclamationmark.arrow.trianglehead.2.clockwise.rotate.90|驚嘆號 警告 箭頭
arrows|exclamationmark.arrow.trianglehead.counterclockwise.rotate.90|驚嘆號 警告 箭頭
arrows|florinsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|francsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|gearshape.arrow.trianglehead.2.clockwise.rotate.90|設定 齒輪 箭頭
arrows|guaranisign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|heat.waves|波浪
arrows|heat.waves.circle|波浪 圓形
arrows|heat.waves.circle.fill|波浪 圓形
arrows|hryvniasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|indianrupeesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|kipsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|larisign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|leaf.arrow.trianglehead.clockwise|葉子 箭頭
arrows|lirasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|location|位置 定位
arrows|location.app|位置 定位
arrows|location.app.fill|位置 定位
arrows|location.circle|位置 定位 圓形
arrows|location.circle.fill|位置 定位 圓形
arrows|location.fill|位置 定位
arrows|location.north|位置 定位
arrows|location.north.circle|位置 定位 圓形
arrows|location.north.circle.fill|位置 定位 圓形
arrows|location.north.fill|位置 定位
arrows|location.north.line|位置 定位
arrows|location.north.line.fill|位置 定位
arrows|location.slash|位置 定位 正斜線
arrows|location.slash.circle|位置 定位 正斜線 圓形
arrows|location.slash.circle.fill|位置 定位 正斜線 圓形
arrows|location.slash.fill|位置 定位 正斜線
arrows|location.square|位置 定位 方形
arrows|location.square.fill|位置 定位 方形
arrows|malaysianringgitsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|manatsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|memories|箭頭 播放
arrows|memories.badge.checkmark|勾 勾選
arrows|memories.badge.minus|減號 箭頭 播放
arrows|memories.badge.plus|加號 新增 箭頭 播放
arrows|memories.badge.xmark|叉 關閉
arrows|memories.slash|正斜線 箭頭 播放
arrows|millsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|minus.arrow.trianglehead.counterclockwise|減號 箭頭
arrows|music.note.arrow.trianglehead.clockwise|音樂 音符 備註 箭頭
arrows|nairasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|norwegiankronesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|person.2.arrow.trianglehead.counterclockwise|人 人物 箭頭 人們
arrows|peruviansolessign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|pesetasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|pesosign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|plus.arrow.trianglehead.clockwise|加號 新增 箭頭
arrows|plus.arrow.trianglehead.counterclockwise|加號 新增 箭頭
arrows|polishzlotysign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|repeat|重複 箭頭
arrows|repeat.1|重複 箭頭
arrows|repeat.1.circle|重複 圓形 箭頭
arrows|repeat.1.circle.fill|重複 圓形 箭頭
arrows|repeat.badge.xmark|重複 叉 關閉 箭頭
arrows|repeat.circle|重複 圓形 箭頭
arrows|repeat.circle.fill|重複 圓形 箭頭
arrows|return|
arrows|return.left|左
arrows|return.right|右
arrows|rublesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|rupeesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|shekelsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|shuffle|隨機 箭頭
arrows|shuffle.circle|隨機 圓形 箭頭
arrows|shuffle.circle.fill|隨機 圓形 箭頭
arrows|singaporedollarsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|slider.horizontal.2.arrow.trianglehead.counterclockwise|箭頭
arrows|sterlingsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|swedishkronasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|tengesign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|text.append|箭頭 播放
arrows|text.insert|箭頭 播放
arrows|tugriksign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|turkishlirasign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|vent.heat.waves.upward|波浪
arrows|wonsign.arrow.trianglehead.counterclockwise.rotate.90|箭頭
arrows|yensign.arrow.trianglehead.counterclockwise.rotate.90|日圓 箭頭
devices|4k.tv|電視
devices|4k.tv.fill|電視
devices|arcade.stick.console|
devices|arcade.stick.console.fill|
devices|arrow.turn.up.forward.iphone|箭頭 上 快轉 手機
devices|arrow.turn.up.forward.iphone.fill|箭頭 上 快轉 手機
devices|audio.jack.mono|
devices|audio.jack.stereo|
devices|av.remote|
devices|av.remote.fill|
devices|backpack.sensor.tag.radiowaves.left.and.right|背包 標籤 左 右
devices|backpack.sensor.tag.radiowaves.left.and.right.fill|背包 標籤 左 右
devices|bicycle.sensor.tag.radiowaves.left.and.right|腳踏車 單車 標籤 左 右
devices|bicycle.sensor.tag.radiowaves.left.and.right.fill|腳踏車 單車 標籤 左 右
devices|briefcase.sensor.tag.radiowaves.left.and.right|公事包 標籤 左 右
devices|briefcase.sensor.tag.radiowaves.left.and.right.fill|公事包 標籤 左 右
devices|button.horizontal.top|
devices|button.horizontal.top.fill|
devices|button.horizontal.top.press|
devices|button.horizontal.top.press.fill|
devices|button.vertical.left|左
devices|button.vertical.left.fill|左
devices|button.vertical.left.press|左
devices|button.vertical.left.press.fill|左
devices|button.vertical.right|右
devices|button.vertical.right.fill|右
devices|button.vertical.right.press|右
devices|button.vertical.right.press.fill|右
devices|cable.coaxial|
devices|cable.connector|
devices|cable.connector.horizontal|
devices|cable.connector.slash|正斜線
devices|cable.connector.video|影片 錄影
devices|camera.sensor.tag.radiowaves.left.and.right|相機 拍照 標籤 左 右
devices|camera.sensor.tag.radiowaves.left.and.right.fill|相機 拍照 標籤 左 右
devices|candybarphone|
devices|circle.filled.ipad|圓形 平板
devices|circle.filled.ipad.fill|圓形 平板
devices|circle.filled.ipad.landscape|圓形 平板
devices|circle.filled.ipad.landscape.fill|圓形 平板
devices|circle.filled.iphone|圓形 手機
devices|circle.filled.iphone.fill|圓形 手機
devices|computermouse|
devices|computermouse.fill|
devices|desktopcomputer|電腦
devices|desktopcomputer.and.arrow.down|電腦 箭頭 下
devices|desktopcomputer.badge.checkmark|電腦 勾 勾選
devices|desktopcomputer.badge.shield.checkmark|電腦 盾牌 勾 勾選
devices|desktopcomputer.trianglebadge.exclamationmark|電腦 驚嘆號 警告
devices|display|螢幕
devices|display.2|螢幕
devices|display.and.arrow.down|螢幕 箭頭 下
devices|display.and.screwdriver|螢幕 螺絲起子
devices|display.trianglebadge.exclamationmark|螢幕 驚嘆號 警告
devices|dot.scope.display|螢幕
devices|dot.scope.laptopcomputer|筆電
devices|earbud.left|左 喇叭 音量
devices|earbud.right|右 喇叭 音量
devices|earbuds|喇叭 音量
devices|earbuds.bone.conduction|骨頭 喇叭 音量
devices|earbuds.bone.conduction.left|骨頭 左 喇叭 音量
devices|earbuds.bone.conduction.right|骨頭 右 喇叭 音量
devices|earbuds.case|喇叭 音量
devices|earbuds.case.fill|喇叭 音量
devices|earbuds.in.ear|耳朵 喇叭 音量
devices|earbuds.in.ear.left|耳朵 左 喇叭 音量
devices|earbuds.in.ear.right|耳朵 右 喇叭 音量
devices|earbuds.stemless|喇叭 音量
devices|earbuds.stemless.left|左 喇叭 音量
devices|earbuds.stemless.right|右 喇叭 音量
devices|faxmachine|
devices|faxmachine.fill|
devices|flipphone|
devices|gamecontroller|遊戲 手把
devices|gamecontroller.circle|遊戲 手把 圓形
devices|gamecontroller.circle.fill|遊戲 手把 圓形
devices|gamecontroller.fill|遊戲 手把
devices|handbag.sensor.tag.radiowaves.left.and.right|手提包 標籤 左 右
devices|handbag.sensor.tag.radiowaves.left.and.right.fill|手提包 標籤 左 右
devices|headphones|耳機 喇叭 音量
devices|headphones.circle|耳機 圓形 喇叭 音量
devices|headphones.circle.fill|耳機 圓形 喇叭 音量
devices|headphones.dots|耳機 喇叭 音量
devices|headphones.over.ear|耳機 耳朵 喇叭 音量
devices|headphones.sensor.tag.radiowaves.left.and.right|耳機 標籤 左 右
devices|headphones.sensor.tag.radiowaves.left.and.right.fill|耳機 標籤 左 右
devices|headphones.slash|耳機 正斜線 喇叭 音量
devices|hifispeaker|喇叭 音量
devices|hifispeaker.2|喇叭 音量
devices|hifispeaker.2.badge.checkmark|勾 勾選 喇叭 音量
devices|hifispeaker.2.badge.checkmark.fill|勾 勾選 喇叭 音量
devices|hifispeaker.2.badge.exclamationmark|驚嘆號 警告 喇叭 音量
devices|hifispeaker.2.badge.exclamationmark.fill|驚嘆號 警告 喇叭 音量
devices|hifispeaker.2.badge.minus|減號 喇叭 音量
devices|hifispeaker.2.badge.minus.fill|減號 喇叭 音量
devices|hifispeaker.2.badge.plus|加號 新增 喇叭 音量
devices|hifispeaker.2.badge.plus.fill|加號 新增 喇叭 音量
devices|hifispeaker.2.fill|喇叭 音量
devices|hifispeaker.arrow.forward|箭頭 快轉 喇叭 音量
devices|hifispeaker.arrow.forward.fill|箭頭 快轉 喇叭 音量
devices|hifispeaker.badge.checkmark|勾 勾選 喇叭 音量
devices|hifispeaker.badge.checkmark.fill|勾 勾選 喇叭 音量
devices|hifispeaker.badge.exclamationmark|驚嘆號 警告 喇叭 音量
devices|hifispeaker.badge.exclamationmark.fill|驚嘆號 警告 喇叭 音量
devices|hifispeaker.badge.minus|減號 喇叭 音量
devices|hifispeaker.badge.minus.fill|減號 喇叭 音量
devices|hifispeaker.badge.plus|加號 新增 喇叭 音量
devices|hifispeaker.badge.plus.fill|加號 新增 喇叭 音量
devices|hifispeaker.fill|喇叭 音量
devices|inset.filled.tv|電視
devices|ipad.and.arrow.forward|平板 箭頭 快轉
devices|iphone.and.arrow.forward.inward|手機 箭頭 快轉
devices|iphone.and.arrow.forward.outward|手機 箭頭 快轉
devices|iphone.and.arrow.right.inward|手機 箭頭 右
devices|iphone.and.arrow.right.outward|手機 箭頭 右
devices|iphone.pattern.diagonalline|手機
devices|iphone.pattern.diagonalline.on.rectangle.portrait.dashed|手機 長方形
devices|jacket.sensor.tag.radiowaves.left.and.right|標籤 左 右
devices|jacket.sensor.tag.radiowaves.left.and.right.fill|標籤 左 右
devices|key.sensor.tag.radiowaves.left.and.right|鑰匙 標籤 左 右
devices|key.sensor.tag.radiowaves.left.and.right.fill|鑰匙 標籤 左 右
devices|keyboard|鍵盤
devices|keyboard.badge.ellipsis|鍵盤 省略號
devices|keyboard.badge.ellipsis.fill|鍵盤 省略號
devices|keyboard.badge.eye|鍵盤 眼睛
devices|keyboard.badge.eye.fill|鍵盤 眼睛
devices|keyboard.chevron.compact.down|鍵盤 下
devices|keyboard.chevron.compact.down.fill|鍵盤 下
devices|keyboard.chevron.compact.left|鍵盤 左
devices|keyboard.chevron.compact.left.fill|鍵盤 左
devices|keyboard.fill|鍵盤
devices|keyboard.onehanded.left|鍵盤 左
devices|keyboard.onehanded.left.fill|鍵盤 左
devices|keyboard.onehanded.right|鍵盤 右
devices|keyboard.onehanded.right.fill|鍵盤 右
devices|laptopcomputer|筆電
devices|laptopcomputer.and.arrow.down|筆電 箭頭 下
devices|laptopcomputer.badge.checkmark|筆電 勾 勾選
devices|laptopcomputer.display.clean|筆電 螢幕
devices|laptopcomputer.slash|筆電 正斜線
devices|laptopcomputer.trianglebadge.exclamationmark|筆電 驚嘆號 警告
devices|lock.desktopcomputer|鎖 鎖定 電腦
devices|lock.display|鎖 鎖定 螢幕
devices|lock.ipad|鎖 鎖定 平板
devices|lock.iphone|鎖 鎖定 手機
devices|lock.laptopcomputer|鎖 鎖定 筆電
devices|lock.open.desktopcomputer|鎖 鎖定 電腦
devices|lock.open.display|鎖 鎖定 螢幕
devices|lock.open.ipad|鎖 鎖定 平板
devices|lock.open.iphone|鎖 鎖定 手機
devices|lock.open.laptopcomputer|鎖 鎖定 筆電
devices|mediastick|
devices|music.note.tv|音樂 音符 備註 電視
devices|music.note.tv.fill|音樂 音符 備註 電視
devices|pc|
devices|photo.tv|照片 相片 電視 山 太陽
devices|platter.2.filled.ipad|平板
devices|platter.2.filled.ipad.landscape|平板
devices|platter.2.filled.iphone|手機
devices|platter.2.filled.iphone.landscape|手機
devices|platter.filled.bottom.and.arrow.down.iphone|箭頭 下 手機
devices|platter.filled.bottom.iphone|手機
devices|platter.filled.top.and.arrow.up.iphone|箭頭 上 手機
devices|platter.filled.top.iphone|手機
devices|play.desktopcomputer|播放 電腦
devices|play.display|播放 螢幕
devices|play.laptopcomputer|播放 筆電
devices|play.tv|播放 電視
devices|play.tv.fill|播放 電視
devices|printer|印表機 郵件
devices|printer.dotmatrix|印表機
devices|printer.dotmatrix.fill|印表機
devices|printer.dotmatrix.filled.and.paper|印表機
devices|printer.dotmatrix.filled.and.paper.inverse|印表機
devices|printer.dotmatrix.inverse|印表機
devices|printer.fill|印表機 郵件
devices|printer.filled.and.paper|印表機
devices|printer.filled.and.paper.inverse|印表機
devices|printer.inverse|印表機 郵件
devices|rectangle.landscape.rotate|長方形 箭頭
devices|rectangle.landscape.rotate.slash|長方形 正斜線 箭頭
devices|rectangle.portrait.rotate|長方形 箭頭
devices|rectangle.portrait.rotate.slash|長方形 正斜線 箭頭
devices|ring.light|戒指
devices|scanner|
devices|scanner.fill|
devices|sensor.radiowaves.left.and.right|左 右
devices|sensor.radiowaves.left.and.right.fill|左 右
devices|server.rack|
devices|smartphone|
devices|sparkles.tv|閃亮 星光 電視
devices|sparkles.tv.fill|閃亮 星光 電視
devices|tv|電視
devices|tv.and.hifispeaker.fill|電視
devices|tv.and.mediabox|電視
devices|tv.and.mediabox.fill|電視
devices|tv.badge.wifi|電視 無線網路
devices|tv.badge.wifi.fill|電視 無線網路
devices|tv.circle|電視 圓形
devices|tv.circle.fill|電視 圓形
devices|tv.fill|電視
devices|tv.slash|電視 正斜線
devices|tv.slash.fill|電視 正斜線
devices|umbrella.sensor.tag.radiowaves.left.and.right|雨傘 標籤 左 右
devices|umbrella.sensor.tag.radiowaves.left.and.right.fill|雨傘 標籤 左 右
devices|wallet.sensor.tag.radiowaves.left.and.right|錢包 標籤 左 右
devices|wallet.sensor.tag.radiowaves.left.and.right.fill|錢包 標籤 左 右
gaming|a.circle|圓形
gaming|a.circle.fill|圓形
gaming|arcade.stick|
gaming|arcade.stick.and.arrow.down|箭頭 下
gaming|arcade.stick.and.arrow.left|箭頭 左
gaming|arcade.stick.and.arrow.left.and.arrow.right.outward|箭頭 左 右
gaming|arcade.stick.and.arrow.right|箭頭 右
gaming|arcade.stick.and.arrow.up|箭頭 上
gaming|arcade.stick.and.arrow.up.and.arrow.down|箭頭 上 下
gaming|arrowkeys|
gaming|arrowkeys.down.filled|下
gaming|arrowkeys.fill|
gaming|arrowkeys.left.filled|左
gaming|arrowkeys.right.filled|右
gaming|arrowkeys.up.filled|上
gaming|b.circle|圓形
gaming|b.circle.fill|圓形
gaming|button.angledbottom.horizontal.left|左
gaming|button.angledbottom.horizontal.left.fill|左
gaming|button.angledbottom.horizontal.right|右
gaming|button.angledbottom.horizontal.right.fill|右
gaming|button.angledtop.vertical.left|左
gaming|button.angledtop.vertical.left.fill|左
gaming|button.angledtop.vertical.right|右
gaming|button.angledtop.vertical.right.fill|右
gaming|button.horizontal|
gaming|button.horizontal.fill|
gaming|button.roundedbottom.horizontal|
gaming|button.roundedbottom.horizontal.fill|
gaming|button.roundedtop.horizontal|
gaming|button.roundedtop.horizontal.fill|
gaming|c.circle|圓形
gaming|c.circle.fill|圓形
gaming|circle.circle|圓形
gaming|circle.circle.fill|圓形
gaming|circle.grid.cross|圓形 格狀 十字
gaming|circle.grid.cross.down.filled|圓形 格狀 十字 下
gaming|circle.grid.cross.fill|圓形 格狀 十字
gaming|circle.grid.cross.left.filled|圓形 格狀 十字 左
gaming|circle.grid.cross.right.filled|圓形 格狀 十字 右
gaming|circle.grid.cross.up.filled|圓形 格狀 十字 上
gaming|circle.square|圓形 方形
gaming|circle.square.fill|圓形 方形
gaming|dpad|
gaming|dpad.down.filled|下
gaming|dpad.fill|
gaming|dpad.left.filled|左
gaming|dpad.right.filled|右
gaming|dpad.up.filled|上
gaming|formfitting.gamecontroller|遊戲 手把
gaming|formfitting.gamecontroller.fill|遊戲 手把
gaming|gearshift.layout.sixspeed|
gaming|house|房子 家 首頁
gaming|house.circle|房子 家 首頁 圓形
gaming|house.circle.fill|房子 家 首頁 圓形
gaming|house.fill|房子 家 首頁
gaming|house.slash|房子 家 首頁 正斜線
gaming|house.slash.fill|房子 家 首頁 正斜線
gaming|l.button.roundedbottom.horizontal|
gaming|l.button.roundedbottom.horizontal.fill|
gaming|l.circle|圓形
gaming|l.circle.fill|圓形
gaming|l.joystick|搖桿
gaming|l.joystick.fill|搖桿
gaming|l.joystick.press.down|搖桿 下
gaming|l.joystick.press.down.fill|搖桿 下
gaming|l.joystick.tilt.down|搖桿 下
gaming|l.joystick.tilt.down.fill|搖桿 下
gaming|l.joystick.tilt.left|搖桿 左
gaming|l.joystick.tilt.left.fill|搖桿 左
gaming|l.joystick.tilt.right|搖桿 右
gaming|l.joystick.tilt.right.fill|搖桿 右
gaming|l.joystick.tilt.up|搖桿 上
gaming|l.joystick.tilt.up.fill|搖桿 上
gaming|l1.button.roundedbottom.horizontal|
gaming|l1.button.roundedbottom.horizontal.fill|
gaming|l1.circle|圓形
gaming|l1.circle.fill|圓形
gaming|l2.button.angledtop.vertical.left|左
gaming|l2.button.angledtop.vertical.left.fill|左
gaming|l2.button.roundedtop.horizontal|
gaming|l2.button.roundedtop.horizontal.fill|
gaming|l2.circle|圓形
gaming|l2.circle.fill|圓形
gaming|l3.button.angledbottom.horizontal.left|左
gaming|l3.button.angledbottom.horizontal.left.fill|左
gaming|l4.button.horizontal|
gaming|l4.button.horizontal.fill|
gaming|lb.button.roundedbottom.horizontal|
gaming|lb.button.roundedbottom.horizontal.fill|
gaming|lb.circle|圓形
gaming|lb.circle.fill|圓形
gaming|line.3.horizontal.button.angledtop.vertical.right|右
gaming|line.3.horizontal.button.angledtop.vertical.right.fill|右
gaming|line.3.horizontal.circle|圓形
gaming|line.3.horizontal.circle.fill|圓形
gaming|lm.button.horizontal|
gaming|lm.button.horizontal.fill|
gaming|lsb.button.angledbottom.horizontal.left|左
gaming|lsb.button.angledbottom.horizontal.left.fill|左
gaming|lt.button.roundedtop.horizontal|
gaming|lt.button.roundedtop.horizontal.fill|
gaming|lt.circle|圓形
gaming|lt.circle.fill|圓形
gaming|m1.button.horizontal|
gaming|m1.button.horizontal.fill|
gaming|m2.button.horizontal|
gaming|m2.button.horizontal.fill|
gaming|m3.button.horizontal|
gaming|m3.button.horizontal.fill|
gaming|m4.button.horizontal|
gaming|m4.button.horizontal.fill|
gaming|minus|減號
gaming|minus.circle|減號 圓形
gaming|minus.circle.fill|減號 圓形
gaming|p1.button.horizontal|
gaming|p1.button.horizontal.fill|
gaming|p2.button.horizontal|
gaming|p2.button.horizontal.fill|
gaming|p3.button.horizontal|
gaming|p3.button.horizontal.fill|
gaming|p4.button.horizontal|
gaming|p4.button.horizontal.fill|
gaming|paddleshifter.left|左
gaming|paddleshifter.left.fill|左
gaming|paddleshifter.right|右
gaming|paddleshifter.right.fill|右
gaming|pedal.accelerator|
gaming|pedal.accelerator.fill|
gaming|pedal.brake|
gaming|pedal.brake.fill|
gaming|pedal.clutch|
gaming|pedal.clutch.fill|
gaming|pl.button.horizontal|
gaming|pl.button.horizontal.fill|
gaming|plus|加號 新增
gaming|plus.circle|加號 新增 圓形
gaming|plus.circle.fill|加號 新增 圓形
gaming|pr.button.horizontal|
gaming|pr.button.horizontal.fill|
gaming|r.button.roundedbottom.horizontal|
gaming|r.button.roundedbottom.horizontal.fill|
gaming|r.circle|圓形
gaming|r.circle.fill|圓形
gaming|r.joystick|搖桿
gaming|r.joystick.fill|搖桿
gaming|r.joystick.press.down|搖桿 下
gaming|r.joystick.press.down.fill|搖桿 下
gaming|r.joystick.tilt.down|搖桿 下
gaming|r.joystick.tilt.down.fill|搖桿 下
gaming|r.joystick.tilt.left|搖桿 左
gaming|r.joystick.tilt.left.fill|搖桿 左
gaming|r.joystick.tilt.right|搖桿 右
gaming|r.joystick.tilt.right.fill|搖桿 右
gaming|r.joystick.tilt.up|搖桿 上
gaming|r.joystick.tilt.up.fill|搖桿 上
gaming|r1.button.roundedbottom.horizontal|
gaming|r1.button.roundedbottom.horizontal.fill|
gaming|r1.circle|圓形
gaming|r1.circle.fill|圓形
gaming|r2.button.angledtop.vertical.right|右
gaming|r2.button.angledtop.vertical.right.fill|右
gaming|r2.button.roundedtop.horizontal|
gaming|r2.button.roundedtop.horizontal.fill|
gaming|r2.circle|圓形
gaming|r2.circle.fill|圓形
gaming|r3.button.angledbottom.horizontal.right|右
gaming|r3.button.angledbottom.horizontal.right.fill|右
gaming|r4.button.horizontal|
gaming|r4.button.horizontal.fill|
gaming|rb.button.roundedbottom.horizontal|
gaming|rb.button.roundedbottom.horizontal.fill|
gaming|rb.circle|圓形
gaming|rb.circle.fill|圓形
gaming|rectangle.fill.on.rectangle.fill|長方形
gaming|rectangle.on.rectangle|長方形
gaming|rectangle.on.rectangle.button.angledtop.vertical.left|長方形 左
gaming|rectangle.on.rectangle.button.angledtop.vertical.left.fill|長方形 左
gaming|rectangle.on.rectangle.circle|長方形 圓形
gaming|rectangle.on.rectangle.circle.fill|長方形 圓形
gaming|rectangle.on.rectangle.square|長方形 方形
gaming|rectangle.on.rectangle.square.fill|長方形 方形
gaming|rm.button.horizontal|
gaming|rm.button.horizontal.fill|
gaming|rsb.button.angledbottom.horizontal.right|右
gaming|rsb.button.angledbottom.horizontal.right.fill|右
gaming|rt.button.roundedtop.horizontal|
gaming|rt.button.roundedtop.horizontal.fill|
gaming|rt.circle|圓形
gaming|rt.circle.fill|圓形
gaming|square.circle|方形 圓形
gaming|square.circle.fill|方形 圓形
gaming|triangle.circle|三角形 圓形
gaming|triangle.circle.fill|三角形 圓形
gaming|x.circle|圓形
gaming|x.circle.fill|圓形
gaming|xmark|叉 關閉 停止
gaming|xmark.circle|叉 關閉 圓形 停止
gaming|xmark.circle.fill|叉 關閉 圓形 停止
gaming|y.circle|圓形
gaming|y.circle.fill|圓形
gaming|z.circle|圓形
gaming|z.circle.fill|圓形
gaming|zl.button.roundedtop.horizontal|
gaming|zl.button.roundedtop.horizontal.fill|
gaming|zr.button.roundedtop.horizontal|
gaming|zr.button.roundedtop.horizontal.fill|
home|air.conditioner.horizontal|
home|air.conditioner.horizontal.fill|
home|air.conditioner.vertical|
home|air.conditioner.vertical.fill|
home|air.purifier|
home|air.purifier.fill|
home|balloon|氣球 派對
home|balloon.2|氣球 派對
home|balloon.2.fill|氣球 派對
home|balloon.fill|氣球 派對
home|bathtub|澡盆
home|bathtub.fill|澡盆
home|blinds.horizontal.closed|
home|blinds.horizontal.open|
home|blinds.vertical.closed|
home|blinds.vertical.open|
home|button.programmable|
home|button.programmable.square|方形
home|button.programmable.square.fill|方形
home|cabinet|櫃子
home|cabinet.fill|櫃子
home|carbon.dioxide.cloud|雲
home|carbon.dioxide.cloud.fill|雲
home|carbon.monoxide.cloud|雲
home|carbon.monoxide.cloud.fill|雲
home|chair|椅子
home|chair.fill|椅子
home|chair.lounge|椅子
home|chair.lounge.fill|椅子
home|chandelier|
home|chandelier.fill|
home|contact.sensor|
home|contact.sensor.fill|
home|cooktop|
home|cooktop.fill|
home|curtains.closed|
home|curtains.open|
home|dehumidifier|
home|dehumidifier.fill|
home|dishwasher|
home|dishwasher.circle|圓形
home|dishwasher.circle.fill|圓形
home|dishwasher.fill|
home|door.french.closed|門
home|door.french.open|門
home|door.garage.closed|門
home|door.garage.closed.trianglebadge.exclamationmark|門 驚嘆號 警告
home|door.garage.double.bay.closed|門
home|door.garage.double.bay.closed.trianglebadge.exclamationmark|門 驚嘆號 警告
home|door.garage.double.bay.open|門
home|door.garage.double.bay.open.trianglebadge.exclamationmark|門 驚嘆號 警告
home|door.garage.open|門
home|door.garage.open.trianglebadge.exclamationmark|門 驚嘆號 警告
home|door.left.hand.closed|門 左 手
home|door.left.hand.open|門 左 手
home|door.right.hand.closed|門 右 手
home|door.right.hand.open|門 右 手
home|door.sliding.left.hand.closed|門 左 手
home|door.sliding.left.hand.open|門 左 手
home|door.sliding.right.hand.closed|門 右 手
home|door.sliding.right.hand.open|門 右 手
home|drop.keypad.rectangle|水滴 長方形
home|drop.keypad.rectangle.fill|水滴 長方形
home|dryer|
home|dryer.circle|圓形
home|dryer.circle.fill|圓形
home|dryer.fill|
home|entry.lever.keypad|
home|entry.lever.keypad.fill|
home|entry.lever.keypad.trianglebadge.exclamationmark|驚嘆號 警告
home|entry.lever.keypad.trianglebadge.exclamationmark.fill|驚嘆號 警告
home|fan.and.light.ceiling|
home|fan.and.light.ceiling.fill|
home|fan.ceiling|
home|fan.ceiling.fill|
home|fan.desk|
home|fan.desk.fill|
home|fan.floor|
home|fan.floor.fill|
home|fan.oscillation|
home|fan.oscillation.fill|
home|figure.walk.arrival|人形 走路 人 人物
home|figure.walk.departure|人形 走路 人 人物
home|fireplace|
home|fireplace.fill|
home|frying.pan|煎蛋
home|frying.pan.fill|煎蛋
home|heater.vertical|
home|heater.vertical.fill|
home|hifireceiver|
home|hifireceiver.fill|
home|house.badge.wifi|房子 家 首頁 無線網路
home|house.badge.wifi.fill|房子 家 首頁 無線網路
home|humidifier|
home|humidifier.and.droplets|水滴 水
home|humidifier.and.droplets.fill|水滴 水
home|humidifier.and.ellipsis|省略號
home|humidifier.and.ellipsis.fill|省略號
home|humidifier.fill|
home|lamp.ceiling|燈
home|lamp.ceiling.fill|燈
home|lamp.ceiling.inverse|燈
home|lamp.desk|燈
home|lamp.desk.fill|燈
home|lamp.floor|燈
home|lamp.floor.fill|燈
home|lamp.table|燈
home|lamp.table.fill|燈
home|light.beacon.max|鬧鐘
home|light.beacon.max.fill|鬧鐘
home|light.beacon.min|鬧鐘
home|light.beacon.min.fill|鬧鐘
home|light.cylindrical.ceiling|
home|light.cylindrical.ceiling.fill|
home|light.cylindrical.ceiling.inverse|
home|light.panel|
home|light.panel.fill|
home|light.recessed|
home|light.recessed.3|
home|light.recessed.3.fill|
home|light.recessed.3.inverse|
home|light.recessed.fill|
home|light.recessed.inverse|
home|light.ribbon|緞帶
home|light.ribbon.fill|緞帶
home|light.strip.2|
home|light.strip.2.fill|
home|lightbulb|燈泡
home|lightbulb.2|燈泡
home|lightbulb.2.fill|燈泡
home|lightbulb.circle|燈泡 圓形
home|lightbulb.circle.fill|燈泡 圓形
home|lightbulb.fill|燈泡
home|lightbulb.led|燈泡
home|lightbulb.led.fill|燈泡
home|lightbulb.led.wide|燈泡
home|lightbulb.led.wide.fill|燈泡
home|lightbulb.max|燈泡
home|lightbulb.max.fill|燈泡
home|lightbulb.min|燈泡
home|lightbulb.min.badge.exclamationmark|燈泡 驚嘆號 警告
home|lightbulb.min.badge.exclamationmark.fill|燈泡 驚嘆號 警告
home|lightbulb.min.fill|燈泡
home|lightbulb.slash|燈泡 正斜線
home|lightbulb.slash.fill|燈泡 正斜線
home|lightswitch.off|
home|lightswitch.off.fill|
home|lightswitch.off.square|方形
home|lightswitch.off.square.fill|方形
home|lightswitch.on|
home|lightswitch.on.fill|
home|lightswitch.on.square|方形
home|lightswitch.on.square.fill|方形
home|lock.open.trianglebadge.exclamationmark|鎖 鎖定 驚嘆號 警告 解鎖
home|lock.open.trianglebadge.exclamationmark.fill|鎖 鎖定 驚嘆號 警告 解鎖
home|lock.trianglebadge.exclamationmark|鎖 鎖定 驚嘆號 警告
home|lock.trianglebadge.exclamationmark.fill|鎖 鎖定 驚嘆號 警告
home|microwave|
home|microwave.fill|
home|oven|
home|oven.fill|
home|party.popper|派對 拉炮
home|party.popper.fill|派對 拉炮
home|pedestrian.gate.closed|
home|pedestrian.gate.closed.trianglebadge.exclamationmark|驚嘆號 警告
home|pedestrian.gate.open|
home|pedestrian.gate.open.trianglebadge.exclamationmark|驚嘆號 警告
home|pipe.and.drop|水滴
home|pipe.and.drop.fill|水滴
home|popcorn|爆米花
home|popcorn.circle|爆米花 圓形
home|popcorn.circle.fill|爆米花 圓形
home|popcorn.fill|爆米花
home|poweroutlet.strip|
home|poweroutlet.strip.fill|
home|poweroutlet.type.a|
home|poweroutlet.type.a.fill|
home|poweroutlet.type.a.square|方形
home|poweroutlet.type.a.square.fill|方形
home|poweroutlet.type.b|
home|poweroutlet.type.b.fill|
home|poweroutlet.type.b.square|方形
home|poweroutlet.type.b.square.fill|方形
home|poweroutlet.type.c|
home|poweroutlet.type.c.fill|
home|poweroutlet.type.c.square|方形
home|poweroutlet.type.c.square.fill|方形
home|poweroutlet.type.d|
home|poweroutlet.type.d.fill|
home|poweroutlet.type.d.square|方形
home|poweroutlet.type.d.square.fill|方形
home|poweroutlet.type.e|
home|poweroutlet.type.e.fill|
home|poweroutlet.type.e.square|方形
home|poweroutlet.type.e.square.fill|方形
home|poweroutlet.type.f|
home|poweroutlet.type.f.fill|
home|poweroutlet.type.f.square|方形
home|poweroutlet.type.f.square.fill|方形
home|poweroutlet.type.g|
home|poweroutlet.type.g.fill|
home|poweroutlet.type.g.square|方形
home|poweroutlet.type.g.square.fill|方形
home|poweroutlet.type.h|銀行
home|poweroutlet.type.h.fill|銀行
home|poweroutlet.type.h.square|方形 銀行
home|poweroutlet.type.h.square.fill|方形 銀行
home|poweroutlet.type.i|
home|poweroutlet.type.i.fill|
home|poweroutlet.type.i.square|方形
home|poweroutlet.type.i.square.fill|方形
home|poweroutlet.type.j|
home|poweroutlet.type.j.fill|
home|poweroutlet.type.j.square|方形
home|poweroutlet.type.j.square.fill|方形
home|poweroutlet.type.k|
home|poweroutlet.type.k.fill|
home|poweroutlet.type.k.square|方形
home|poweroutlet.type.k.square.fill|方形
home|poweroutlet.type.l|
home|poweroutlet.type.l.fill|
home|poweroutlet.type.l.square|方形
home|poweroutlet.type.l.square.fill|方形
home|poweroutlet.type.m|
home|poweroutlet.type.m.fill|
home|poweroutlet.type.m.square|方形
home|poweroutlet.type.m.square.fill|方形
home|poweroutlet.type.n|
home|poweroutlet.type.n.fill|
home|poweroutlet.type.n.square|方形
home|poweroutlet.type.n.square.fill|方形
home|poweroutlet.type.o|
home|poweroutlet.type.o.fill|
home|poweroutlet.type.o.square|方形
home|poweroutlet.type.o.square.fill|方形
home|refrigerator|
home|refrigerator.fill|
home|robotic.vacuum|
home|robotic.vacuum.and.arrowtriangle.up|上
home|robotic.vacuum.and.arrowtriangle.up.fill|上
home|robotic.vacuum.and.ellipsis|省略號
home|robotic.vacuum.and.ellipsis.fill|省略號
home|robotic.vacuum.fill|
home|roller.shade.closed|
home|roller.shade.open|
home|roman.shade.closed|
home|roman.shade.open|
home|sensor|
home|sensor.fill|
home|shower|淋浴
home|shower.fill|淋浴
home|shower.handheld|淋浴
home|shower.handheld.fill|淋浴
home|shower.sidejet|淋浴
home|shower.sidejet.fill|淋浴
home|sink|
home|sink.fill|
home|sofa|沙發
home|sofa.fill|沙發
home|spigot|
home|spigot.fill|
home|sprinkler|
home|sprinkler.and.droplets|水滴 水
home|sprinkler.and.droplets.fill|水滴 水
home|sprinkler.fill|
home|square.split.bottomrightquarter|方形
home|square.split.bottomrightquarter.fill|方形
home|stairs|
home|stove|
home|stove.fill|
home|switch.programmable|
home|switch.programmable.fill|
home|switch.programmable.square|方形
home|switch.programmable.square.fill|方形
home|table.furniture|
home|table.furniture.fill|
home|thermometer.and.ellipsis|溫度計 溫度 省略號
home|toilet|馬桶 露營
home|toilet.circle|馬桶 圓形 露營
home|toilet.circle.fill|馬桶 圓形 露營
home|toilet.fill|馬桶 露營
home|video.doorbell|影片 錄影
home|video.doorbell.fill|影片 錄影
home|videoprojector|
home|videoprojector.fill|
home|washer|
home|washer.circle|圓形
home|washer.circle.fill|圓形
home|washer.fill|
home|web.camera|相機 拍照
home|web.camera.fill|相機 拍照
home|wifi.router|無線網路
home|wifi.router.fill|無線網路
home|window.awning|窗戶
home|window.awning.closed|窗戶
home|window.casement|窗戶
home|window.casement.closed|窗戶
home|window.ceiling|窗戶
home|window.ceiling.closed|窗戶
home|window.horizontal|窗戶
home|window.horizontal.closed|窗戶
home|window.shade.closed|窗戶
home|window.shade.open|窗戶
home|window.vertical.closed|窗戶
home|window.vertical.open|窗戶
transportation|airplane|飛機
transportation|airplane.arrival|飛機
transportation|airplane.circle|飛機 圓形
transportation|airplane.circle.fill|飛機 圓形
transportation|airplane.cloud|飛機 雲
transportation|airplane.departure|飛機
transportation|airplane.landed|飛機
transportation|airplane.path.dotted|飛機
transportation|airplane.ticket|飛機 票
transportation|airplane.ticket.fill|飛機 票
transportation|airplane.up.forward|飛機 上 快轉
transportation|airplane.up.forward.app|飛機 上 快轉
transportation|airplane.up.forward.app.fill|飛機 上 快轉
transportation|airplane.up.right|飛機 上 右
transportation|airplane.up.right.app|飛機 上 右
transportation|airplane.up.right.app.fill|飛機 上 右
transportation|airplaneseat|
transportation|cablecar|
transportation|cablecar.fill|
transportation|car.card|汽車 車
transportation|car.card.fill|汽車 車
transportation|car.ferry|汽車 車 渡輪
transportation|car.ferry.fill|汽車 車 渡輪
transportation|ferry|渡輪
transportation|ferry.fill|渡輪
transportation|lightrail|
transportation|lightrail.fill|
transportation|moped|
transportation|moped.fill|
transportation|motorcycle|機車
transportation|motorcycle.fill|機車
transportation|scooter|
transportation|train.side.front.car|火車 汽車 車
transportation|train.side.middle.car|火車 汽車 車
transportation|train.side.rear.car|火車 汽車 車
transportation|tram.card|電車
transportation|tram.card.fill|電車
transportation|tram.circle.fill|電車 圓形
transportation|tram.fill.tunnel|電車
transportation|truck.box|盒子
transportation|truck.box.badge.clock|盒子 時鐘 時間
transportation|truck.box.badge.clock.fill|盒子 時鐘 時間
transportation|truck.box.fill|盒子
transportation|xmark.circle.badge.airplane|叉 關閉 圓形 飛機
transportation|xmark.circle.badge.airplane.fill|叉 關閉 圓形 飛機
editing|align.horizontal.center|長方形
editing|align.horizontal.center.fill|長方形
editing|align.horizontal.left|左 長方形
editing|align.horizontal.left.fill|左 長方形
editing|align.horizontal.right|右 長方形
editing|align.horizontal.right.fill|右 長方形
editing|align.vertical.bottom|長方形
editing|align.vertical.bottom.fill|長方形
editing|align.vertical.center|長方形
editing|align.vertical.center.fill|長方形
editing|align.vertical.top|長方形
editing|align.vertical.top.fill|長方形
editing|aspectratio|
editing|aspectratio.fill|
editing|bandage|繃帶
editing|bandage.fill|繃帶
editing|beziercurve|
editing|circle.dashed|圓形
editing|circle.lefthalf.filled|圓形
editing|circle.lefthalf.filled.inverse|圓形
editing|circle.righthalf.filled|圓形
editing|circle.righthalf.filled.inverse|圓形
editing|crop|
editing|crop.rotate|箭頭
editing|dial.high|
editing|dial.high.fill|
editing|dial.low|
editing|dial.low.fill|
editing|dial.medium|
editing|dial.medium.fill|
editing|distribute.horizontal|長方形
editing|distribute.horizontal.center|長方形
editing|distribute.horizontal.center.fill|長方形
editing|distribute.horizontal.fill|長方形
editing|distribute.horizontal.left|左 長方形
editing|distribute.horizontal.left.fill|左 長方形
editing|distribute.horizontal.right|右 長方形
editing|distribute.horizontal.right.fill|右 長方形
editing|distribute.vertical|長方形
editing|distribute.vertical.bottom|長方形
editing|distribute.vertical.bottom.fill|長方形
editing|distribute.vertical.center|長方形
editing|distribute.vertical.center.fill|長方形
editing|distribute.vertical.fill|長方形
editing|distribute.vertical.top|長方形
editing|distribute.vertical.top.fill|長方形
editing|eraser|
editing|eraser.fill|
editing|eraser.line.dashed|
editing|eraser.line.dashed.fill|
editing|eyedropper|
editing|eyedropper.and.sparkles|閃亮 星光
editing|eyedropper.full|
editing|eyedropper.halffull|
editing|guidepoint.horizontal|
editing|guidepoint.vertical|
editing|guidepoint.vertical.arrowtriangle.forward|快轉
editing|guidepoint.vertical.numbers|
editing|highlighter|
editing|highlighter.badge.ellipsis|省略號
editing|inset.filled.circle.dashed|圓形
editing|inset.filled.square.dashed|方形
editing|inset.filled.square.dashed.micro|方形
editing|inset.left.half.filled.square.dashed.micro|左 方形
editing|inset.left.half.square.dashed.micro|左 方形
editing|inset.square.dashed.micro|方形
editing|lasso|
editing|lasso.badge.sparkles|閃亮 星光
editing|loupe|
editing|move.3d|
editing|paintbrush|畫筆 刷子
editing|paintbrush.fill|畫筆 刷子
editing|paintbrush.pointed|畫筆 刷子
editing|paintbrush.pointed.fill|畫筆 刷子
editing|paintbrush.slash|畫筆 刷子 正斜線
editing|paintbrush.slash.fill|畫筆 刷子 正斜線
editing|pencil|鉛筆
editing|pencil.and.outline|鉛筆
editing|pencil.and.scribble|鉛筆
editing|pencil.circle|鉛筆 圓形
editing|pencil.circle.fill|鉛筆 圓形
editing|pencil.line|鉛筆
editing|pencil.slash|鉛筆 正斜線
editing|rectangle.and.pencil.and.ellipsis|長方形 鉛筆 省略號
editing|rectangle.dashed|長方形
editing|rectangle.dashed.badge.record|長方形
editing|rotate.3d|
editing|rotate.3d.circle|圓形
editing|rotate.3d.circle.fill|圓形
editing|rotate.3d.fill|
editing|rotate.left|左
editing|rotate.left.fill|左
editing|rotate.right|右
editing|rotate.right.fill|右
editing|scale.3d|
editing|scissors|剪刀
editing|scissors.badge.ellipsis|剪刀 省略號
editing|scissors.circle|剪刀 圓形
editing|scissors.circle.fill|剪刀 圓形
editing|scribble|
editing|scribble.variable|
editing|selection.pin.in.out|圖釘
editing|skew|
editing|slider.horizontal.2.square|方形
editing|slider.horizontal.2.square.badge.arrow.down|方形 箭頭 下
editing|slider.horizontal.2.square.on.square|方形
editing|slider.horizontal.3|
editing|slider.horizontal.below.circle.lefthalf.filled|圓形
editing|slider.horizontal.below.circle.lefthalf.filled.inverse|圓形
editing|slider.horizontal.below.circle.righthalf.filled|圓形
editing|slider.horizontal.below.circle.righthalf.filled.inverse|圓形
editing|slider.horizontal.below.rectangle|長方形
editing|slider.horizontal.below.square.and.square.filled|方形
editing|slider.horizontal.below.square.filled.and.square|方形
editing|slider.horizontal.below.sun.max|太陽
editing|slider.horizontal.below.sun.min|太陽
editing|slider.vertical.3|
editing|square.and.pencil|方形 鉛筆 郵件
editing|square.and.pencil.circle|方形 鉛筆 圓形 郵件
editing|square.and.pencil.circle.fill|方形 鉛筆 圓形 郵件
editing|square.dashed|方形
editing|square.dashed.micro|方形
editing|timeline.selection|
editing|wand.and.outline|魔杖
editing|wand.and.outline.inverse|魔杖
editing|wand.and.rays|魔杖
editing|wand.and.rays.inverse|魔杖
editing|wand.and.sparkles|魔杖 閃亮 星光
editing|wand.and.sparkles.inverse|魔杖 閃亮 星光
health|allergens|
health|allergens.fill|
health|bed.double|床
health|bed.double.badge.checkmark|床 勾 勾選
health|bed.double.badge.checkmark.fill|床 勾 勾選
health|bed.double.circle|床 圓形
health|bed.double.circle.fill|床 圓形
health|bed.double.fill|床
health|blood.pressure.cuff|
health|blood.pressure.cuff.badge.gauge.with.needle|
health|blood.pressure.cuff.badge.gauge.with.needle.fill|
health|blood.pressure.cuff.fill|
health|bolt.heart|閃電 愛心 心
health|bolt.heart.fill|閃電 愛心 心
health|brain|大腦
health|brain.fill|大腦
health|brain.filled.head.profile|大腦
health|brain.head.profile|大腦
health|brain.head.profile.fill|大腦
health|bubbles.and.sparkles|泡泡 閃亮 星光
health|bubbles.and.sparkles.fill|泡泡 閃亮 星光
health|chart.line.text.clipboard|圖表 寫字夾板 音符 備註
health|chart.line.text.clipboard.fill|圖表 寫字夾板 音符 備註
health|cross|十字
health|cross.case|十字
health|cross.case.circle|十字 圓形
health|cross.case.circle.fill|十字 圓形
health|cross.case.fill|十字
health|cross.circle|十字 圓形
health|cross.circle.fill|十字 圓形
health|cross.fill|十字
health|cross.vial|十字
health|cross.vial.fill|十字
health|facemask|
health|facemask.fill|
health|heart|愛心 心
health|heart.badge.bolt|愛心 心 閃電
health|heart.badge.bolt.fill|愛心 心 閃電
health|heart.badge.bolt.slash|愛心 心 閃電 正斜線
health|heart.badge.bolt.slash.fill|愛心 心 閃電 正斜線
health|heart.circle|愛心 心 圓形
health|heart.circle.fill|愛心 心 圓形
health|heart.fill|愛心 心
health|heart.text.clipboard|愛心 心 寫字夾板 音符 備註
health|heart.text.clipboard.fill|愛心 心 寫字夾板 音符 備註
health|heart.text.square|愛心 心 方形
health|heart.text.square.fill|愛心 心 方形
health|ivfluid.bag|包包 袋
health|ivfluid.bag.fill|包包 袋
health|list.bullet.clipboard|清單 項目號 寫字夾板 音符 備註
health|list.bullet.clipboard.fill|清單 項目號 寫字夾板 音符 備註
health|list.clipboard|清單 寫字夾板 音符 備註
health|list.clipboard.fill|清單 寫字夾板 音符 備註
health|lock.heart|鎖 鎖定 愛心 心
health|lock.heart.fill|鎖 鎖定 愛心 心
health|lungs|肺
health|lungs.fill|肺
health|medical.thermometer|溫度計 溫度
health|medical.thermometer.fill|溫度計 溫度
health|microbe|微生物
health|microbe.circle|微生物 圓形
health|microbe.circle.fill|微生物 圓形
health|microbe.fill|微生物
health|pencil.and.list.clipboard|鉛筆 清單 寫字夾板 音符 備註
health|pill|藥丸
health|pill.circle|藥丸 圓形
health|pill.circle.fill|藥丸 圓形
health|pill.fill|藥丸
health|pills|藥
health|pills.circle|藥 圓形
health|pills.circle.fill|藥 圓形
health|pills.fill|藥
health|sparkle.text.clipboard|火花 寫字夾板 音符 備註
health|sparkle.text.clipboard.fill|火花 寫字夾板 音符 備註
health|staroflife|
health|staroflife.circle|圓形
health|staroflife.circle.fill|圓形
health|staroflife.fill|
health|stethoscope|聽診器
health|stethoscope.circle|聽診器 圓形
health|stethoscope.circle.fill|聽診器 圓形
health|syringe|針筒
health|syringe.fill|針筒
health|thermometer.variable|溫度計 溫度
health|thermometer.variable.and.figure|溫度計 溫度 人形
health|thermometer.variable.and.figure.circle|溫度計 溫度 人形 圓形
health|thermometer.variable.and.figure.circle.fill|溫度計 溫度 人形 圓形
health|thermometer.variable.badge.clock|溫度計 溫度 時鐘 時間
health|thermometer.variable.badge.play|溫度計 溫度 播放
health|vial.viewfinder|
health|waveform.path.ecg|
health|waveform.path.ecg.rectangle|長方形
health|waveform.path.ecg.rectangle.fill|長方形
health|waveform.path.ecg.text.clipboard|寫字夾板 音符 備註
health|waveform.path.ecg.text.clipboard.fill|寫字夾板 音符 備註
keyboard|alt|
keyboard|capslock|
keyboard|capslock.fill|
keyboard|chevron.backward.to.line|倒轉
keyboard|chevron.forward.to.line|快轉
keyboard|chevron.left.to.line|左
keyboard|chevron.right.to.line|右
keyboard|clear|
keyboard|clear.fill|
keyboard|command|
keyboard|command.circle|圓形
keyboard|command.circle.fill|圓形
keyboard|command.square|方形
keyboard|command.square.fill|方形
keyboard|control|
keyboard|delete.backward|倒轉
keyboard|delete.backward.fill|倒轉
keyboard|delete.forward|快轉
keyboard|delete.forward.fill|快轉
keyboard|delete.left|左
keyboard|delete.left.fill|左
keyboard|delete.right|右
keyboard|delete.right.fill|右
keyboard|eject|
keyboard|eject.circle|圓形
keyboard|eject.circle.fill|圓形
keyboard|eject.fill|
keyboard|escape|箭頭
keyboard|globe|地球
keyboard|globe.badge.chevron.backward|地球 倒轉
keyboard|globe.fill|地球
keyboard|light.max|
keyboard|light.min|
keyboard|mount|
keyboard|mount.fill|
keyboard|option|
keyboard|power|
keyboard|power.circle|圓形
keyboard|power.circle.fill|圓形
keyboard|power.dotted|
keyboard|projective|
keyboard|shift|
keyboard|shift.fill|
keyboard|space|
keyboard|sun.max|太陽
keyboard|sun.max.circle|太陽 圓形
keyboard|sun.max.circle.fill|太陽 圓形
keyboard|sun.max.fill|太陽
keyboard|sun.min|太陽
keyboard|sun.min.fill|太陽
other|alternatingcurrent|
other|app.background.dotted|
other|app.badge|
other|app.badge.checkmark|勾 勾選
other|app.badge.checkmark.fill|勾 勾選
other|app.badge.clock|時鐘 時間
other|app.badge.clock.fill|時鐘 時間
other|app.badge.fill|
other|app.dashed|
other|app.gift|禮物
other|app.gift.fill|禮物
other|app.grid|格狀
other|app.grid.2x2|格狀
other|app.grid.2x2.and.person.fill|格狀 人 人物
other|app.grid.2x2.bottom.dashed|格狀
other|app.grid.2x2.bottom.dashed.fill|格狀
other|app.grid.2x2.fill|格狀
other|app.grid.2x2.topleading.dashed|格狀
other|app.grid.2x2.topleading.dashed.fill|格狀
other|app.grid.2x2.topleading.filled|格狀
other|app.grid.2x2.topleft.dashed|格狀
other|app.grid.2x2.topleft.dashed.fill|格狀
other|app.grid.2x2.topleft.filled|格狀
other|app.shadow|
other|app.slash|正斜線
other|app.slash.fill|正斜線
other|app.specular|
other|app.translucent|
other|append.page|
other|append.page.fill|
other|apple.books.pages|書
other|apple.books.pages.fill|書
other|apple.classical.pages|
other|apple.classical.pages.fill|
other|apple.podcasts.pages|
other|apple.podcasts.pages.fill|
other|apple.terminal|
other|apple.terminal.circle|圓形
other|apple.terminal.circle.fill|圓形
other|apple.terminal.fill|
other|apple.terminal.on.rectangle|長方形
other|apple.terminal.on.rectangle.fill|長方形
other|appwindow.swipe.rectangle|長方形
other|aqi.medium.gauge.open|
other|arrow.down.app.dashed|箭頭 下
other|arrow.down.app.dashed.trianglebadge.exclamationmark|箭頭 下 驚嘆號 警告
other|arrowtriangle.backward.inset.filled.leadingthird.rectangle|倒轉 長方形
other|arrowtriangle.backward.leadingside.rectangle|倒轉 長方形
other|arrowtriangle.forward.inset.filled.trailingthird.rectangle|快轉 長方形
other|arrowtriangle.forward.trailingside.rectangle|快轉 長方形
other|arrowtriangle.left.inset.filled.leftthird.rectangle|左 長方形
other|arrowtriangle.left.leftside.rectangle|左 長方形
other|arrowtriangle.right.inset.filled.rightthird.rectangle|右 長方形
other|arrowtriangle.right.rightside.rectangle|右 長方形
other|asterisk|星號
other|asterisk.circle|星號 圓形
other|asterisk.circle.fill|星號 圓形
other|at|
other|at.badge.minus|減號
other|at.badge.plus|加號 新增
other|at.circle|圓形
other|at.circle.fill|圓形
other|badge.plus.radiowaves.forward|加號 新增 快轉 右
other|badge.plus.radiowaves.right|加號 新增 右
other|barcode|條碼
other|barcode.viewfinder|條碼
other|bolt.house|閃電 房子 家 首頁
other|bolt.house.fill|閃電 房子 家 首頁
other|bolt.ring.closed|閃電 戒指
other|book.pages|書 書本
other|book.pages.fill|書 書本
other|building.classical.columns|
other|building.classical.columns.circle|圓形
other|building.classical.columns.fill|
other|building.columns.circle.fill|圓形
other|burn|
other|burst|
other|burst.fill|
other|calendar.day.timeline.leading|日曆 日期
other|calendar.day.timeline.leading.circle|日曆 日期 圓形
other|calendar.day.timeline.leading.circle.fill|日曆 日期 圓形
other|calendar.day.timeline.left|日曆 日期 左
other|calendar.day.timeline.left.circle|日曆 日期 左 圓形
other|calendar.day.timeline.left.circle.fill|日曆 日期 左 圓形
other|calendar.day.timeline.right|日曆 日期 右
other|calendar.day.timeline.right.circle|日曆 日期 右 圓形
other|calendar.day.timeline.right.circle.fill|日曆 日期 右 圓形
other|calendar.day.timeline.trailing|日曆 日期
other|calendar.day.timeline.trailing.circle|日曆 日期 圓形
other|calendar.day.timeline.trailing.circle.fill|日曆 日期 圓形
other|capsule.bottomhalf.filled|
other|capsule.lefthalf.filled|
other|capsule.on.capsule|
other|capsule.on.capsule.fill|
other|capsule.on.rectangle|長方形
other|capsule.on.rectangle.fill|長方形
other|capsule.on.rectangle.liquid.glass|長方形
other|capsule.on.rectangle.liquid.glass.fill|長方形
other|capsule.portrait.bottomhalf.filled|
other|capsule.portrait.lefthalf.filled|
other|capsule.portrait.righthalf.filled|
other|capsule.portrait.tophalf.filled|
other|capsule.righthalf.filled|
other|capsule.tophalf.filled|
other|character.cursor.ibeam.mni|
other|chart.bar|圖表
other|chart.bar.fill|圖表
other|chart.bar.horizontal.page|圖表
other|chart.bar.horizontal.page.fill|圖表
other|chart.bar.xaxis|圖表
other|chart.bar.xaxis.ascending|圖表
other|chart.bar.xaxis.ascending.badge.clock|圖表 時鐘 時間
other|chart.bar.xaxis.descending|圖表
other|chart.bar.yaxis|圖表
other|chart.dots.scatter|圖表
other|chart.line.downtrend.xyaxis|圖表
other|chart.line.downtrend.xyaxis.circle|圖表 圓形
other|chart.line.downtrend.xyaxis.circle.fill|圖表 圓形
other|chart.line.flattrend.xyaxis|圖表
other|chart.line.flattrend.xyaxis.circle|圖表 圓形
other|chart.line.flattrend.xyaxis.circle.fill|圖表 圓形
other|chart.line.uptrend.xyaxis|圖表
other|chart.line.uptrend.xyaxis.circle|圖表 圓形
other|chart.line.uptrend.xyaxis.circle.fill|圖表 圓形
other|chart.pie|圖表 派
other|chart.pie.fill|圖表 派
other|checkmark.app|勾 勾選
other|checkmark.app.fill|勾 勾選
other|checkmark.arrow.trianglehead.clockwise|勾 勾選 箭頭
other|checkmark.rectangle.stack|勾 勾選 長方形
other|checkmark.rectangle.stack.fill|勾 勾選 長方形
other|checkmark.seal.text.page|勾 勾選 海豹
other|checkmark.seal.text.page.fill|勾 勾選 海豹
other|chevron.left.forwardslash.chevron.right|左 右
other|circle.badge.checkmark|圓形 勾 勾選
other|circle.badge.checkmark.fill|圓形 勾 勾選
other|circle.badge.exclamationmark|圓形 驚嘆號 警告
other|circle.badge.exclamationmark.fill|圓形 驚嘆號 警告
other|circle.badge.minus|圓形 減號
other|circle.badge.minus.fill|圓形 減號
other|circle.badge.plus|圓形 加號 新增
other|circle.badge.plus.fill|圓形 加號 新增
other|circle.badge.questionmark|圓形 問號
other|circle.badge.questionmark.fill|圓形 問號
other|circle.badge.xmark|圓形 叉 關閉
other|circle.badge.xmark.fill|圓形 叉 關閉
other|circle.bottomhalf.filled|圓形
other|circle.bottomhalf.filled.inverse|圓形
other|circle.dotted|圓形
other|circle.grid.2x1|圓形 格狀
other|circle.grid.2x1.fill|圓形 格狀
other|circle.grid.2x1.left.filled|圓形 格狀 左
other|circle.grid.2x1.right.filled|圓形 格狀 右
other|circle.grid.2x2|圓形 格狀
other|circle.grid.2x2.fill|圓形 格狀
other|circle.grid.2x2.topleft.checkmark.filled|圓形 格狀 勾 勾選
other|circle.grid.3x3|圓形 格狀
other|circle.grid.3x3.circle|圓形 格狀
other|circle.grid.3x3.circle.fill|圓形 格狀
other|circle.grid.3x3.fill|圓形 格狀
other|circle.hexagongrid|圓形
other|circle.hexagongrid.circle|圓形
other|circle.hexagongrid.circle.fill|圓形
other|circle.hexagongrid.fill|圓形
other|circle.on.app.liquid.glass|圓形
other|circle.on.app.liquid.glass.fill|圓形
other|circle.on.square|圓形 方形
other|circle.on.square.intersection.dotted|圓形 方形 交集
other|circle.on.square.merge|圓形 方形
other|circle.slash|圓形 正斜線
other|circle.slash.fill|圓形 正斜線
other|circle.tophalf.filled|圓形
other|circle.tophalf.filled.inverse|圓形
other|circlebadge|
other|circlebadge.2|
other|circlebadge.2.fill|
other|circlebadge.fill|
other|coat.circle|外套 圓形
other|coat.circle.fill|外套 圓形
other|cone|
other|cone.fill|
other|cube.transparent|
other|cube.transparent.fill|
other|curlybraces|
other|curlybraces.square|方形
other|curlybraces.square.fill|方形
other|cylinder|
other|cylinder.fill|
other|cylinder.split.1x2|
other|cylinder.split.1x2.fill|
other|diamond.bottomhalf.filled|
other|diamond.circle|圓形
other|diamond.circle.fill|圓形
other|diamond.lefthalf.filled|
other|diamond.righthalf.filled|
other|diamond.tophalf.filled|
other|directcurrent|
other|dock.arrow.down.rectangle|箭頭 下 長方形
other|dock.arrow.up.rectangle|箭頭 上 長方形
other|dock.rectangle|長方形
other|dot.circle.viewfinder|圓形
other|dot.crosshair|
other|dot.square|方形
other|dot.square.fill|方形
other|dot.squareshape|
other|dot.squareshape.fill|
other|dot.squareshape.split.2x2|格狀
other|dot.viewfinder|
other|dots.and.line.vertical.and.pointer.arrow.rectangle|箭頭 長方形
other|ellipsis|省略號
other|ellipsis.circle|省略號 圓形
other|ellipsis.circle.badge|省略號 圓形
other|ellipsis.circle.badge.fill|省略號 圓形
other|ellipsis.circle.fill|省略號 圓形
other|ellipsis.curlybraces|省略號
other|ellipsis.rectangle|省略號 長方形
other|ellipsis.rectangle.fill|省略號 長方形
other|ellipsis.viewfinder|省略號
other|envelope.and.arrow.3.down|信封 郵件 箭頭 下
other|envelope.and.arrow.3.down.fill|信封 郵件 箭頭 下
other|eraser.badge.xmark|叉 關閉
other|eraser.badge.xmark.fill|叉 關閉
other|eraser.slash|正斜線
other|eraser.slash.fill|正斜線
other|eraser.trianglebadge.exclamationmark|驚嘆號 警告
other|eraser.trianglebadge.exclamationmark.fill|驚嘆號 警告
other|exclamationmark|驚嘆號 警告
other|exclamationmark.2|驚嘆號 警告
other|exclamationmark.3|驚嘆號 警告
other|exclamationmark.octagon|驚嘆號 警告 停止
other|exclamationmark.octagon.fill|驚嘆號 警告 停止
other|exclamationmark.questionmark|驚嘆號 警告 問號
other|exclamationmark.triangle.text.page|驚嘆號 警告 三角形
other|exclamationmark.triangle.text.page.fill|驚嘆號 警告 三角形
other|exclamationmark.viewfinder|驚嘆號 警告
other|fan.gauge.open|
other|fibrechannel|
other|filemenu.and.selection|
other|flame.gauge.open|火焰 火
other|flowchart|
other|flowchart.fill|
other|fn|
other|fx|
other|gauge.open|
other|gear.badge|齒輪 設定
other|gear.badge.checkmark|齒輪 設定 勾 勾選
other|gear.badge.questionmark|齒輪 設定 問號
other|gear.badge.xmark|齒輪 設定 叉 關閉
other|gear.circle|齒輪 設定 圓形
other|gear.circle.fill|齒輪 設定 圓形
other|gearshape.circle|設定 齒輪 圓形
other|gearshape.circle.fill|設定 齒輪 圓形
other|grid|格狀
other|grid.circle|格狀 圓形
other|grid.circle.fill|格狀 圓形
other|h.square.on.square|方形
other|h.square.on.square.fill|方形
other|heart.gauge.open|愛心 心
other|heart.rectangle|愛心 心 長方形
other|heart.rectangle.fill|愛心 心 長方形
other|heart.slash|愛心 心 正斜線
other|heart.slash.circle|愛心 心 正斜線 圓形
other|heart.slash.circle.fill|愛心 心 正斜線 圓形
other|heart.slash.fill|愛心 心 正斜線
other|heart.square|愛心 心 方形
other|heart.square.fill|愛心 心 方形
other|heat.waves.gauge.open|波浪
other|helm|
other|hexagon.bottomhalf.filled|
other|hexagon.lefthalf.filled|
other|hexagon.righthalf.filled|
other|hexagon.tophalf.filled|
other|info|資訊
other|info.app|資訊
other|info.app.fill|資訊
other|info.circle|資訊 圓形
other|info.circle.badge|資訊 圓形
other|info.circle.badge.fill|資訊 圓形
other|info.circle.fill|資訊 圓形
other|info.circle.text.page|資訊 圓形
other|info.circle.text.page.fill|資訊 圓形
other|info.triangle|資訊 三角形
other|info.triangle.fill|資訊 三角形
other|inset.filled.bottomhalf.rectangle|長方形
other|inset.filled.bottomhalf.rectangle.portrait|長方形
other|inset.filled.bottomhalf.tophalf.rectangle|長方形
other|inset.filled.bottomleading.bottomtrailing.rectangle|長方形
other|inset.filled.bottomleading.rectangle|長方形
other|inset.filled.bottomleading.rectangle.portrait|長方形
other|inset.filled.bottomleft.bottomright.rectangle|長方形
other|inset.filled.bottomleft.rectangle|長方形
other|inset.filled.bottomleft.rectangle.portrait|長方形
other|inset.filled.bottomright.rectangle|長方形
other|inset.filled.bottomright.rectangle.portrait|長方形
other|inset.filled.bottomthird.rectangle|長方形
other|inset.filled.bottomthird.rectangle.portrait|長方形
other|inset.filled.bottomthird.square|方形
other|inset.filled.bottomtrailing.rectangle|長方形
other|inset.filled.bottomtrailing.rectangle.portrait|長方形
other|inset.filled.capsule|
other|inset.filled.capsule.portrait|
other|inset.filled.center.rectangle|長方形
other|inset.filled.center.rectangle.badge.plus|長方形 加號 新增
other|inset.filled.center.rectangle.portrait|長方形
other|inset.filled.circle|圓形
other|inset.filled.circle.slash|圓形 正斜線
other|inset.filled.diamond|
other|inset.filled.leadinghalf.arrow.leading.rectangle|箭頭 長方形
other|inset.filled.leadinghalf.arrowtriangle.backward.rectangle|倒轉 長方形
other|inset.filled.leadinghalf.rectangle|長方形
other|inset.filled.leadinghalf.rectangle.portrait|長方形
other|inset.filled.leadinghalf.toptrailing.bottomtrailing.rectangle|長方形
other|inset.filled.leadinghalf.trailinghalf.rectangle|長方形
other|inset.filled.leadingthird.rectangle|長方形
other|inset.filled.leadingthird.rectangle.badge.xmark|長方形 叉 關閉
other|inset.filled.leadingthird.rectangle.portrait|長方形
other|inset.filled.leadingthird.square|方形
other|inset.filled.lefthalf.arrow.left.rectangle|箭頭 左 長方形
other|inset.filled.lefthalf.arrowtriangle.left.rectangle|左 長方形
other|inset.filled.lefthalf.rectangle|長方形
other|inset.filled.lefthalf.rectangle.portrait|長方形
other|inset.filled.lefthalf.righthalf.rectangle|長方形
other|inset.filled.lefthalf.topright.bottomright.rectangle|長方形
other|inset.filled.leftthird.middlethird.rightthird.rectangle|長方形
other|inset.filled.leftthird.rectangle|長方形
other|inset.filled.leftthird.rectangle.badge.xmark|長方形 叉 關閉
other|inset.filled.leftthird.rectangle.portrait|長方形
other|inset.filled.leftthird.square|方形
other|inset.filled.oval|
other|inset.filled.oval.portrait|
other|inset.filled.pano|
other|inset.filled.rectangle|長方形
other|inset.filled.rectangle.on.rectangle|長方形
other|inset.filled.rectangle.portrait|長方形
other|inset.filled.righthalf.arrow.right.rectangle|箭頭 右 長方形
other|inset.filled.righthalf.arrowtriangle.right.rectangle|右 長方形
other|inset.filled.righthalf.lefthalf.rectangle|長方形
other|inset.filled.righthalf.rectangle|長方形
other|inset.filled.righthalf.rectangle.portrait|長方形
other|inset.filled.rightthird.rectangle|長方形
other|inset.filled.rightthird.rectangle.badge.xmark|長方形 叉 關閉
other|inset.filled.rightthird.rectangle.portrait|長方形
other|inset.filled.rightthird.square|方形
other|inset.filled.square|方形
other|inset.filled.tophalf.bottomhalf.rectangle|長方形
other|inset.filled.tophalf.bottomleft.bottomright.rectangle|長方形
other|inset.filled.tophalf.rectangle|長方形
other|inset.filled.tophalf.rectangle.portrait|長方形
other|inset.filled.topleading.bottomleading.trailinghalf.rectangle|長方形
other|inset.filled.topleading.rectangle|長方形
other|inset.filled.topleading.rectangle.portrait|長方形
other|inset.filled.topleft.bottomleft.righthalf.rectangle|長方形
other|inset.filled.topleft.rectangle|長方形
other|inset.filled.topleft.rectangle.portrait|長方形
other|inset.filled.topleft.topright.bottomhalf.rectangle|長方形
other|inset.filled.topleft.topright.bottomleft.bottomright.rectangle|長方形
other|inset.filled.topright.rectangle|長方形
other|inset.filled.topright.rectangle.portrait|長方形
other|inset.filled.topthird.middlethird.bottomthird.rectangle|長方形
other|inset.filled.topthird.rectangle|長方形
other|inset.filled.topthird.rectangle.portrait|長方形
other|inset.filled.topthird.square|方形
other|inset.filled.toptrailing.rectangle|長方形
other|inset.filled.toptrailing.rectangle.portrait|長方形
other|inset.filled.trailinghalf.arrow.trailing.rectangle|箭頭 長方形
other|inset.filled.trailinghalf.arrowtriangle.forward.rectangle|快轉 長方形
other|inset.filled.trailinghalf.leadinghalf.rectangle|長方形
other|inset.filled.trailinghalf.rectangle|長方形
other|inset.filled.trailinghalf.rectangle.portrait|長方形
other|inset.filled.trailingthird.rectangle|長方形
other|inset.filled.trailingthird.rectangle.badge.xmark|長方形 叉 關閉
other|inset.filled.trailingthird.rectangle.portrait|長方形
other|inset.filled.trailingthird.square|方形
other|inset.filled.triangle|三角形
other|interface.window|窗戶
other|interface.window.and.pointer.arrow|窗戶 箭頭
other|interface.window.badge.plus|窗戶 加號 新增
other|interface.window.dashed|窗戶
other|interface.window.on.rectangle|窗戶 長方形
other|interface.window.on.rectangle.dashed|窗戶 長方形
other|interface.window.stack|窗戶
other|j.square.on.square|方形
other|j.square.on.square.fill|方形
other|jacket.circle|圓形
other|jacket.circle.fill|圓形
other|k|
other|keyboard.interface.window|鍵盤 窗戶
other|laurel.leading.laurel.trailing|
other|left|左
other|left.circle|左 圓形
other|left.circle.fill|左 圓形
other|line.2.horizontal.decrease.circle|圓形
other|line.2.horizontal.decrease.circle.fill|圓形
other|line.3.crossed.swirl.circle|圓形
other|line.3.crossed.swirl.circle.fill|圓形
other|line.3.horizontal|
other|line.3.horizontal.decrease|
other|line.3.horizontal.decrease.circle|圓形 郵件
other|line.3.horizontal.decrease.circle.fill|圓形 郵件
other|line.horizontal.star.fill.line.horizontal|星星 星
other|lines.measurement.horizontal|
other|lines.measurement.horizontal.aligned.bottom|
other|lines.measurement.vertical|
other|lineweight|
other|list.and.film|清單 底片 電影
other|list.bullet.below.rectangle|清單 項目號 長方形
other|list.bullet.rectangle|清單 項目號 長方形
other|list.bullet.rectangle.fill|清單 項目號 長方形
other|list.bullet.rectangle.portrait|清單 項目號 長方形
other|list.bullet.rectangle.portrait.fill|清單 項目號 長方形
other|list.dash.header.rectangle|清單 長方形
other|list.dash.header.rectangle.fill|清單 長方形
other|location.fill.viewfinder|位置 定位
other|location.viewfinder|位置 定位
other|lock.app.dashed|鎖 鎖定
other|lock.rectangle.dashed|鎖 鎖定 長方形
other|lock.rectangle.on.rectangle.dashed|鎖 鎖定 長方形 右
other|long.text.page.and.pencil|鉛筆
other|long.text.page.and.pencil.fill|鉛筆
other|mail|郵件
other|mail.and.text.magnifyingglass|郵件 放大鏡 搜尋
other|mail.fill|郵件
other|mail.stack|郵件
other|mail.stack.fill|郵件
other|menubar.arrow.down.rectangle|箭頭 下 長方形
other|menubar.arrow.up.rectangle|箭頭 上 長方形
other|menubar.dock.rectangle|長方形
other|menubar.dock.rectangle.badge.record|長方形
other|menubar.rectangle|長方形
other|minus.arrow.trianglehead.clockwise|減號 箭頭
other|minus.diamond|減號
other|minus.diamond.fill|減號
other|minus.plus.lines.measurement.horizontal.aligned.bottom|減號 加號 新增
other|minus.rectangle.portrait|減號 長方形
other|minus.rectangle.portrait.fill|減號 長方形
other|moon.zzz|月亮 睡著
other|moon.zzz.fill|月亮 睡著
other|moonrise|箭頭
other|moonrise.circle|圓形 箭頭
other|moonrise.circle.fill|圓形 箭頭
other|moonrise.fill|箭頭
other|moonset|箭頭
other|moonset.circle|圓形 箭頭
other|moonset.circle.fill|圓形 箭頭
other|moonset.fill|箭頭
other|mosaic|
other|mosaic.fill|
other|music.note|音樂 音符 備註
other|music.note.list|音樂 音符 備註 清單
other|music.note.slash|音樂 音符 備註 正斜線
other|music.note.square.stack|音樂 音符 備註 方形
other|music.note.square.stack.fill|音樂 音符 備註 方形
other|music.pages|音樂
other|music.pages.fill|音樂
other|music.quarternote.3|音樂
other|octagon.bottomhalf.filled|
other|octagon.lefthalf.filled|
other|octagon.righthalf.filled|
other|octagon.tophalf.filled|
other|oval.bottomhalf.filled|
other|oval.lefthalf.filled|
other|oval.portrait.bottomhalf.filled|
other|oval.portrait.lefthalf.filled|
other|oval.portrait.righthalf.filled|
other|oval.portrait.tophalf.filled|
other|oval.righthalf.filled|
other|oval.tophalf.filled|
other|paint.bucket.classic|水桶
other|pano|
other|pano.badge.play|播放
other|pano.badge.play.fill|播放
other|pano.fill|
other|parentheses|
other|peacesign|
other|pentagon.bottomhalf.filled|
other|pentagon.lefthalf.filled|
other|pentagon.righthalf.filled|
other|pentagon.tophalf.filled|
other|person.building.classical|人 人物
other|person.building.classical.fill|人 人物
other|pip|
other|pip.enter|
other|pip.exit|
other|pip.fill|
other|pip.remove|
other|pip.swap|
other|placeholdertext.fill|
other|play.rectangle.on.rectangle|播放 長方形
other|play.rectangle.on.rectangle.circle|播放 長方形 圓形
other|play.rectangle.on.rectangle.circle.fill|播放 長方形 圓形
other|play.rectangle.on.rectangle.fill|播放 長方形
other|plus.app|加號 新增
other|plus.app.fill|加號 新增
other|plus.capsule|加號 新增
other|plus.capsule.fill|加號 新增
other|plus.circle.dashed|加號 新增 圓形
other|plus.diamond|加號 新增
other|plus.diamond.fill|加號 新增
other|plus.minus.capsule|加號 新增 減號
other|plus.minus.capsule.fill|加號 新增 減號
other|plus.rectangle.fill.on.rectangle.fill|加號 新增 長方形
other|plus.rectangle.on.rectangle|加號 新增 長方形
other|plus.rectangle.portrait|加號 新增 長方形
other|plus.rectangle.portrait.fill|加號 新增 長方形
other|plus.square.dashed|加號 新增 方形
other|plus.square.fill.on.square.fill|加號 新增 方形
other|plus.square.on.square|加號 新增 方形
other|point.3.connected.trianglepath.dotted|
other|point.3.filled.connected.trianglepath.dotted|
other|pointer.arrow|箭頭
other|pointer.arrow.ipad|箭頭 平板
other|pointer.arrow.ipad.slash|箭頭 平板 正斜線
other|pointer.arrow.ipad.slash.square|箭頭 平板 正斜線 方形
other|pointer.arrow.ipad.slash.square.fill|箭頭 平板 正斜線 方形
other|pointer.arrow.ipad.square|箭頭 平板 方形
other|pointer.arrow.ipad.square.fill|箭頭 平板 方形
other|pointer.arrow.slash|箭頭 正斜線
other|pointer.arrow.slash.square|箭頭 正斜線 方形
other|pointer.arrow.slash.square.fill|箭頭 正斜線 方形
other|pointer.arrow.square|箭頭 方形
other|pointer.arrow.square.fill|箭頭 方形
other|poweroff|
other|poweron|
other|powersleep|
other|progress.indicator|
other|purchased|
other|purchased.circle|圓形
other|purchased.circle.fill|圓形
other|pyramid|
other|pyramid.fill|
other|qrcode|二維碼
other|qrcode.viewfinder|二維碼
other|questionmark|問號
other|questionmark.app|問號
other|questionmark.app.dashed|問號
other|questionmark.app.fill|問號
other|questionmark.circle.dashed|問號 圓形
other|questionmark.diamond|問號
other|questionmark.diamond.fill|問號
other|questionmark.square.dashed|問號 方形
other|questionmark.text.page|問號
other|questionmark.text.page.fill|問號
other|r.square.on.square|方形
other|r.square.on.square.fill|方形
other|rays|
other|rectangle.2.swap|長方形
other|rectangle.3.group|長方形
other|rectangle.3.group.dashed|長方形
other|rectangle.3.group.fill|長方形
other|rectangle.3.portrait.pano|長方形
other|rectangle.3.portrait.pano.fill|長方形
other|rectangle.arrowtriangle.2.inward|長方形
other|rectangle.arrowtriangle.2.outward|長方形
other|rectangle.badge.checkmark|長方形 勾 勾選
other|rectangle.badge.minus|長方形 減號
other|rectangle.badge.plus|長方形 加號 新增
other|rectangle.badge.sparkles|長方形 閃亮 星光
other|rectangle.badge.sparkles.fill|長方形 閃亮 星光
other|rectangle.badge.xmark|長方形 叉 關閉
other|rectangle.bottomhalf.filled|長方形
other|rectangle.compress.vertical|長方形
other|rectangle.connected.to.line.below|長方形
other|rectangle.expand.diagonal|長方形
other|rectangle.expand.vertical|長方形
other|rectangle.fill.badge.checkmark|長方形 勾 勾選
other|rectangle.fill.badge.minus|長方形 減號
other|rectangle.fill.badge.plus|長方形 加號 新增
other|rectangle.fill.badge.xmark|長方形 叉 關閉
other|rectangle.fill.on.rectangle.angled.fill|長方形
other|rectangle.grid.1x2|長方形 格狀
other|rectangle.grid.1x2.fill|長方形 格狀
other|rectangle.grid.1x3|長方形 格狀
other|rectangle.grid.1x3.fill|長方形 格狀
other|rectangle.grid.2x2|長方形 格狀
other|rectangle.grid.2x2.fill|長方形 格狀
other|rectangle.grid.3x1|長方形 格狀
other|rectangle.grid.3x1.fill|長方形 格狀
other|rectangle.grid.3x2|長方形 格狀
other|rectangle.grid.3x2.fill|長方形 格狀
other|rectangle.grid.3x3|長方形 格狀
other|rectangle.grid.3x3.fill|長方形 格狀
other|rectangle.leadinghalf.filled|長方形
other|rectangle.lefthalf.filled|長方形
other|rectangle.on.rectangle.angled|長方形
other|rectangle.on.rectangle.badge.gearshape|長方形 設定 齒輪
other|rectangle.on.rectangle.dashed|長方形 右
other|rectangle.on.rectangle.slash|長方形 正斜線
other|rectangle.on.rectangle.slash.circle|長方形 正斜線 圓形
other|rectangle.on.rectangle.slash.circle.fill|長方形 正斜線 圓形
other|rectangle.on.rectangle.slash.fill|長方形 正斜線
other|rectangle.pattern.checkered|長方形
other|rectangle.portrait.and.arrow.forward|長方形 箭頭 快轉
other|rectangle.portrait.and.arrow.forward.fill|長方形 箭頭 快轉
other|rectangle.portrait.and.arrow.right|長方形 箭頭 右
other|rectangle.portrait.and.arrow.right.fill|長方形 箭頭 右
other|rectangle.portrait.arrowtriangle.2.inward|長方形
other|rectangle.portrait.arrowtriangle.2.outward|長方形
other|rectangle.portrait.badge.plus|長方形 加號 新增
other|rectangle.portrait.badge.plus.fill|長方形 加號 新增
other|rectangle.portrait.bottomhalf.filled|長方形
other|rectangle.portrait.lefthalf.filled|長方形
other|rectangle.portrait.on.rectangle.portrait|長方形
other|rectangle.portrait.on.rectangle.portrait.angled|長方形
other|rectangle.portrait.on.rectangle.portrait.angled.fill|長方形
other|rectangle.portrait.on.rectangle.portrait.fill|長方形
other|rectangle.portrait.on.rectangle.portrait.slash|長方形 正斜線
other|rectangle.portrait.on.rectangle.portrait.slash.fill|長方形 正斜線
other|rectangle.portrait.righthalf.filled|長方形
other|rectangle.portrait.slash|長方形 正斜線
other|rectangle.portrait.slash.fill|長方形 正斜線
other|rectangle.portrait.split.2x1|長方形
other|rectangle.portrait.split.2x1.fill|長方形
other|rectangle.portrait.split.2x1.slash|長方形 正斜線
other|rectangle.portrait.split.2x1.slash.fill|長方形 正斜線
other|rectangle.portrait.tophalf.filled|長方形
other|rectangle.ratio.16.to.9|長方形 比率
other|rectangle.ratio.16.to.9.fill|長方形 比率
other|rectangle.ratio.3.to.4|長方形 比率
other|rectangle.ratio.3.to.4.fill|長方形 比率
other|rectangle.ratio.4.to.3|長方形 比率
other|rectangle.ratio.4.to.3.fill|長方形 比率
other|rectangle.ratio.9.to.16|長方形 比率
other|rectangle.ratio.9.to.16.fill|長方形 比率
other|rectangle.righthalf.filled|長方形
other|rectangle.slash|長方形 正斜線
other|rectangle.slash.fill|長方形 正斜線
other|rectangle.split.1x2|長方形
other|rectangle.split.1x2.fill|長方形
other|rectangle.split.2x1|長方形
other|rectangle.split.2x1.fill|長方形
other|rectangle.split.2x1.slash|長方形 正斜線
other|rectangle.split.2x1.slash.fill|長方形 正斜線
other|rectangle.split.2x2|長方形
other|rectangle.split.2x2.fill|長方形
other|rectangle.split.3x1|長方形
other|rectangle.split.3x1.fill|長方形
other|rectangle.split.3x3|長方形
other|rectangle.split.3x3.fill|長方形
other|rectangle.stack.badge.minus|長方形 減號
other|rectangle.stack.badge.play|長方形 播放
other|rectangle.stack.badge.play.fill|長方形 播放
other|rectangle.stack.badge.plus|長方形 加號 新增
other|rectangle.stack.fill.badge.minus|長方形 減號
other|rectangle.stack.fill.badge.plus|長方形 加號 新增
other|rectangle.tophalf.filled|長方形
other|rectangle.trailinghalf.filled|長方形
other|restart|
other|restart.circle|圓形
other|restart.circle.fill|圓形
other|richtext.page|
other|richtext.page.fill|
other|right|右
other|right.circle|右 圓形
other|right.circle.fill|右 圓形
other|sidebar.leading|
other|sidebar.left|左
other|sidebar.right|右
other|sidebar.squares.leading|方形
other|sidebar.squares.left|方形 左
other|sidebar.squares.right|方形 右
other|sidebar.squares.trailing|方形
other|sidebar.trailing|
other|slash.circle|正斜線 圓形
other|slash.circle.fill|正斜線 圓形
other|sleep|
other|sleep.circle|圓形
other|sleep.circle.fill|圓形
other|slider.horizontal.2.rectangle.and.arrow.trianglehead.2.clockwise.rotate.90|長方形 箭頭
other|slowmo|
other|smallcircle.circle|圓形
other|smallcircle.circle.fill|圓形
other|sparkle|火花
other|sparkles.2|閃亮 星光
other|sparkles.rectangle.stack|閃亮 星光 長方形
other|sparkles.rectangle.stack.fill|閃亮 星光 長方形
other|sparkles.square.filled.on.square|閃亮 星光 方形
other|square.and.arrow.down|方形 箭頭 下
other|square.and.arrow.down.badge.checkmark|方形 箭頭 下 勾 勾選
other|square.and.arrow.down.badge.checkmark.fill|方形 箭頭 下 勾 勾選
other|square.and.arrow.down.badge.clock|方形 箭頭 下 時鐘 時間
other|square.and.arrow.down.badge.clock.fill|方形 箭頭 下 時鐘 時間
other|square.and.arrow.down.badge.xmark|方形 箭頭 下 叉 關閉
other|square.and.arrow.down.badge.xmark.fill|方形 箭頭 下 叉 關閉
other|square.and.arrow.down.fill|方形 箭頭 下
other|square.and.arrow.down.on.square|方形 箭頭 下
other|square.and.arrow.down.on.square.fill|方形 箭頭 下
other|square.and.arrow.up|方形 箭頭 上
other|square.and.arrow.up.badge.checkmark|方形 箭頭 上 勾 勾選
other|square.and.arrow.up.badge.checkmark.fill|方形 箭頭 上 勾 勾選
other|square.and.arrow.up.badge.clock|方形 箭頭 上 時鐘 時間
other|square.and.arrow.up.badge.clock.fill|方形 箭頭 上 時鐘 時間
other|square.and.arrow.up.circle|方形 箭頭 上 圓形
other|square.and.arrow.up.circle.fill|方形 箭頭 上 圓形
other|square.and.arrow.up.fill|方形 箭頭 上
other|square.and.arrow.up.on.square|方形 箭頭 上
other|square.and.arrow.up.on.square.fill|方形 箭頭 上
other|square.and.arrow.up.trianglebadge.exclamationmark|方形 箭頭 上 驚嘆號 警告
other|square.and.arrow.up.trianglebadge.exclamationmark.fill|方形 箭頭 上 驚嘆號 警告
other|square.and.at.rectangle|方形 長方形
other|square.and.at.rectangle.fill|方形 長方形
other|square.and.line.vertical.and.square|方形
other|square.and.line.vertical.and.square.filled|方形
other|square.arrowtriangle.4.outward|方形
other|square.badge.plus|方形 加號 新增
other|square.badge.plus.fill|方形 加號 新增
other|square.bottomhalf.filled|方形
other|square.dotted|方形
other|square.fill.and.line.vertical.and.square.fill|方形
other|square.fill.on.circle.fill|方形 圓形
other|square.fill.on.square.fill|方形
other|square.filled.and.line.vertical.and.square|方形
other|square.filled.on.square|方形
other|square.grid.2x2|方形 格狀
other|square.grid.2x2.fill|方形 格狀
other|square.grid.3x1.below.line.grid.1x2|方形 格狀
other|square.grid.3x1.below.line.grid.1x2.fill|方形 格狀
other|square.grid.3x2|方形 格狀
other|square.grid.3x2.fill|方形 格狀
other|square.grid.3x3|方形 格狀
other|square.grid.3x3.fill|方形 格狀
other|square.grid.3x3.square|方形 格狀
other|square.grid.3x3.square.badge.ellipsis|方形 格狀 省略號
other|square.grid.4x3.fill|方形 格狀
other|square.grid.month|方形 格狀
other|square.lefthalf.filled|方形
other|square.on.circle|方形 圓形
other|square.on.square|方形
other|square.on.square.dashed|方形
other|square.on.square.intersection.dashed|方形 交集
other|square.on.square.squareshape.controlhandles|方形
other|square.resize|方形
other|square.resize.down|方形 下
other|square.resize.up|方形 上
other|square.righthalf.filled|方形
other|square.slash|方形 正斜線
other|square.slash.fill|方形 正斜線
other|square.split.1x2|方形
other|square.split.1x2.fill|方形
other|square.split.2x1|方形
other|square.split.2x1.fill|方形
other|square.split.2x2|方形
other|square.split.2x2.fill|方形
other|square.split.diagonal|方形
other|square.split.diagonal.2x2|方形
other|square.split.diagonal.2x2.fill|方形
other|square.split.diagonal.fill|方形
other|square.stack|方形
other|square.stack.3d.down.forward|方形 下 快轉 右
other|square.stack.3d.down.forward.fill|方形 下 快轉 右
other|square.stack.3d.down.right|方形 下 右
other|square.stack.3d.down.right.fill|方形 下 右
other|square.stack.3d.forward.dottedline|方形 快轉
other|square.stack.3d.forward.dottedline.fill|方形 快轉
other|square.stack.3d.up|方形 上
other|square.stack.3d.up.badge.automatic|方形 上
other|square.stack.3d.up.badge.automatic.fill|方形 上
other|square.stack.3d.up.fill|方形 上
other|square.stack.3d.up.slash|方形 上 正斜線
other|square.stack.3d.up.slash.fill|方形 上 正斜線
other|square.stack.3d.up.trianglebadge.exclamationmark|方形 上 驚嘆號 警告
other|square.stack.3d.up.trianglebadge.exclamationmark.fill|方形 上 驚嘆號 警告
other|square.stack.fill|方形
other|square.text.square|方形
other|square.text.square.fill|方形
other|square.tophalf.filled|方形
other|squares.below.rectangle|方形 長方形
other|squares.leading.rectangle|方形 長方形
other|squares.leading.rectangle.fill|方形 長方形
other|squareshape|
other|squareshape.controlhandles.on.squareshape.controlhandles|
other|squareshape.dotted.squareshape|
other|squareshape.fill|
other|squareshape.split.2x2|格狀
other|squareshape.split.2x2.dotted.inside|格狀
other|squareshape.split.2x2.dotted.inside.and.outside|
other|squareshape.split.2x2.dotted.outside|
other|squareshape.split.3x3|格狀
other|squareshape.squareshape.dotted|
other|star|星星 星 郵件
other|star.circle|星星 星 圓形
other|star.circle.fill|星星 星 圓形
other|star.fill|星星 星 郵件
other|star.leadinghalf.filled|星星 星
other|star.rectangle|星星 星 長方形
other|star.rectangle.fill|星星 星 長方形
other|star.slash|星星 星 正斜線
other|star.slash.fill|星星 星 正斜線
other|star.square|星星 星 方形
other|star.square.fill|星星 星 方形
other|star.square.on.square|星星 星 方形
other|star.square.on.square.fill|星星 星 方形
other|storefront|
other|storefront.circle|圓形
other|storefront.circle.fill|圓形
other|storefront.fill|
other|suit.club|
other|suit.club.fill|
other|suit.diamond|
other|suit.diamond.fill|
other|suit.heart|愛心 心
other|suit.heart.fill|愛心 心
other|suit.spade|
other|suit.spade.fill|
other|suitcase.circle|行李箱 旅行 圓形
other|suitcase.circle.fill|行李箱 旅行 圓形
other|sun.lefthalf.filled|太陽
other|sun.righthalf.filled|太陽
other|switch.2|
other|tablecells|
other|tablecells.badge.ellipsis|省略號
other|tablecells.fill|
other|tablecells.fill.badge.ellipsis|省略號
other|target|目標
other|text.and.command.interface.window|窗戶
other|text.badge.checkmark|勾 勾選
other|text.badge.minus|減號
other|text.badge.plus|加號 新增
other|text.badge.star|星星 星
other|text.badge.xmark|叉 關閉
other|text.menu|
other|text.page|
other|text.page.and.line.vertical.and.text.page|
other|text.page.fill|
other|text.page.slash|正斜線
other|text.page.slash.fill|正斜線
other|text.quote|
other|text.rectangle|長方形
other|text.rectangle.fill|長方形
other|text.rectangle.page|長方形
other|text.rectangle.page.fill|長方形
other|text.viewfinder|
other|thermometer.gauge.open|溫度計 溫度
other|timelapse|
other|togglepower|
other|torus|
other|triangle.bottomhalf.filled|三角形
other|triangle.lefthalf.filled|三角形
other|triangle.righthalf.filled|三角形
other|triangle.tophalf.filled|三角形
other|uiwindow.split.2x1|
other|umbrella.gauge.open|雨傘
other|view.2d|
other|view.3d|
other|viewfinder.circle|圓形
other|viewfinder.circle.fill|圓形
other|viewfinder.rectangular|
other|viewfinder.trianglebadge.exclamationmark|驚嘆號 警告
other|wake|
other|wake.circle|圓形
other|wake.circle.fill|圓形
other|waveform.path|
other|waveform.path.badge.minus|減號
other|waveform.path.badge.plus|加號 新增
other|waveform.path.ecg.text|
other|waveform.path.ecg.text.page|
other|waveform.path.ecg.text.page.fill|
other|widget.extralarge|
other|widget.extralarge.badge.plus|加號 新增
other|widget.grid.2x1.rectangle|格狀 長方形
other|widget.grid.2x1.rectangle.fill|格狀 長方形
other|widget.large|
other|widget.large.badge.plus|加號 新增
other|widget.medium|
other|widget.medium.badge.plus|加號 新增
other|widget.small|
other|widget.small.badge.exclamationmark|驚嘆號 警告
other|widget.small.badge.plus|加號 新增
other|xmark.app|叉 關閉
other|xmark.app.fill|叉 關閉
other|xmark.diamond|叉 關閉 乘
other|xmark.diamond.fill|叉 關閉 乘
other|xmark.interface.window|叉 關閉 窗戶
other|xmark.octagon|叉 關閉 乘
other|xmark.octagon.fill|叉 關閉 乘
other|xmark.rectangle|叉 關閉 長方形
other|xmark.rectangle.fill|叉 關閉 長方形
other|xmark.rectangle.portrait|叉 關閉 長方形
other|xmark.rectangle.portrait.fill|叉 關閉 長方形
other|xmark.square|叉 關閉 方形 停止
other|xmark.square.fill|叉 關閉 方形 停止
other|xmark.viewfinder|叉 關閉
other|zipper.page|
other|zzz|睡著
math|angle|銳角
math|compass.drawing|指南針
math|divide|除
math|divide.circle|除 圓形
math|divide.circle.fill|除 圓形
math|divide.square|除 方形
math|divide.square.fill|除 方形
math|equal|等號
math|equal.circle|等號 圓形
math|equal.circle.fill|等號 圓形
math|equal.square|等號 方形
math|equal.square.fill|等號 方形
math|function|
math|graph.2d|
math|graph.3d|
math|greaterthan|
math|greaterthan.circle|圓形
math|greaterthan.circle.fill|圓形
math|greaterthan.square|方形
math|greaterthan.square.fill|方形
math|greaterthanorequalto|
math|greaterthanorequalto.circle|圓形
math|greaterthanorequalto.circle.fill|圓形
math|greaterthanorequalto.square|方形
math|greaterthanorequalto.square.fill|方形
math|lessthan|
math|lessthan.circle|圓形
math|lessthan.circle.fill|圓形
math|lessthan.square|方形
math|lessthan.square.fill|方形
math|lessthanorequalto|
math|lessthanorequalto.circle|圓形
math|lessthanorequalto.circle.fill|圓形
math|lessthanorequalto.square|方形
math|lessthanorequalto.square.fill|方形
math|minus.forwardslash.plus|減號 加號 新增
math|minus.rectangle|減號 長方形
math|minus.rectangle.fill|減號 長方形
math|minus.square|減號 方形
math|minus.square.fill|減號 方形
math|multiply|乘
math|multiply.circle|乘 圓形
math|multiply.circle.fill|乘 圓形
math|multiply.square|乘 方形
math|multiply.square.fill|乘 方形
math|notequal|
math|notequal.circle|圓形
math|notequal.circle.fill|圓形
math|notequal.square|方形
math|notequal.square.fill|方形
math|number.sign|英鎊符號
math|number.sign.circle|圓形 英鎊符號
math|number.sign.circle.fill|圓形 英鎊符號
math|number.sign.square|方形 英鎊符號
math|number.sign.square.fill|方形 英鎊符號
math|percent|百分比
math|pi|
math|pi.circle|圓形
math|pi.circle.fill|圓形
math|pi.square|方形
math|pi.square.fill|方形
math|plus.forwardslash.minus|加號 新增 減號
math|plus.rectangle|加號 新增 長方形
math|plus.rectangle.fill|加號 新增 長方形
math|plus.square|加號 新增 方形
math|plus.square.fill|加號 新增 方形
math|radicand.squareroot|
math|squareroot|
math|sum|
nature|ant|螞蟻 毛毛蟲
nature|ant.circle|螞蟻 圓形 毛毛蟲
nature|ant.circle.fill|螞蟻 圓形 毛毛蟲
nature|ant.fill|螞蟻 毛毛蟲
nature|atom|原子
nature|bird|鳥
nature|bird.circle|鳥 圓形
nature|bird.circle.fill|鳥 圓形
nature|bird.fill|鳥
nature|bolt.shield|閃電 盾牌
nature|bolt.shield.fill|閃電 盾牌
nature|carrot|紅蘿蔔
nature|carrot.fill|紅蘿蔔
nature|cat|貓
nature|cat.circle|貓 圓形
nature|cat.circle.fill|貓 圓形
nature|cat.fill|貓
nature|cloud|雲
nature|cloud.bolt|雲 閃電
nature|cloud.bolt.circle|雲 閃電 圓形
nature|cloud.bolt.circle.fill|雲 閃電 圓形
nature|cloud.bolt.fill|雲 閃電
nature|cloud.bolt.rain|雲 閃電 雨
nature|cloud.bolt.rain.circle|雲 閃電 雨 圓形
nature|cloud.bolt.rain.circle.fill|雲 閃電 雨 圓形
nature|cloud.bolt.rain.fill|雲 閃電 雨
nature|cloud.circle|雲 圓形
nature|cloud.circle.fill|雲 圓形
nature|cloud.drizzle|雲
nature|cloud.drizzle.circle|雲 圓形
nature|cloud.drizzle.circle.fill|雲 圓形
nature|cloud.drizzle.fill|雲
nature|cloud.fill|雲
nature|cloud.fog|雲 有霧
nature|cloud.fog.circle|雲 有霧 圓形
nature|cloud.fog.circle.fill|雲 有霧 圓形
nature|cloud.fog.fill|雲 有霧
nature|cloud.hail|雲
nature|cloud.hail.circle|雲 圓形
nature|cloud.hail.circle.fill|雲 圓形
nature|cloud.hail.fill|雲
nature|cloud.heavyrain|雲
nature|cloud.heavyrain.circle|雲 圓形
nature|cloud.heavyrain.circle.fill|雲 圓形
nature|cloud.heavyrain.fill|雲
nature|cloud.moon|雲 月亮
nature|cloud.moon.bolt|雲 月亮 閃電
nature|cloud.moon.bolt.circle|雲 月亮 閃電 圓形
nature|cloud.moon.bolt.circle.fill|雲 月亮 閃電 圓形
nature|cloud.moon.bolt.fill|雲 月亮 閃電
nature|cloud.moon.circle|雲 月亮 圓形
nature|cloud.moon.circle.fill|雲 月亮 圓形
nature|cloud.moon.fill|雲 月亮
nature|cloud.moon.rain|雲 月亮 雨
nature|cloud.moon.rain.circle|雲 月亮 雨 圓形
nature|cloud.moon.rain.circle.fill|雲 月亮 雨 圓形
nature|cloud.moon.rain.fill|雲 月亮 雨
nature|cloud.rain|雲 雨
nature|cloud.rain.circle|雲 雨 圓形
nature|cloud.rain.circle.fill|雲 雨 圓形
nature|cloud.rain.fill|雲 雨
nature|cloud.rainbow.crop|雲 彩虹
nature|cloud.rainbow.crop.fill|雲 彩虹
nature|cloud.sleet|雲
nature|cloud.sleet.circle|雲 圓形
nature|cloud.sleet.circle.fill|雲 圓形
nature|cloud.sleet.fill|雲
nature|cloud.snow|雲 雪
nature|cloud.snow.circle|雲 雪 圓形
nature|cloud.snow.circle.fill|雲 雪 圓形
nature|cloud.snow.fill|雲 雪
nature|cloud.sun|雲 太陽
nature|cloud.sun.bolt|雲 太陽 閃電
nature|cloud.sun.bolt.circle|雲 太陽 閃電 圓形
nature|cloud.sun.bolt.circle.fill|雲 太陽 閃電 圓形
nature|cloud.sun.bolt.fill|雲 太陽 閃電
nature|cloud.sun.circle|雲 太陽 圓形
nature|cloud.sun.circle.fill|雲 太陽 圓形
nature|cloud.sun.fill|雲 太陽
nature|cloud.sun.rain|雲 太陽 雨
nature|cloud.sun.rain.circle|雲 太陽 雨 圓形
nature|cloud.sun.rain.circle.fill|雲 太陽 雨 圓形
nature|cloud.sun.rain.fill|雲 太陽 雨
nature|dog|狗
nature|dog.circle|狗 圓形
nature|dog.circle.fill|狗 圓形
nature|dog.fill|狗
nature|drop|水滴 水
nature|drop.circle|水滴 圓形 水
nature|drop.circle.fill|水滴 圓形 水
nature|drop.degreesign|水滴 水
nature|drop.degreesign.fill|水滴 水
nature|drop.degreesign.slash|水滴 正斜線 水
nature|drop.degreesign.slash.fill|水滴 正斜線 水
nature|drop.fill|水滴 水
nature|drop.triangle|水滴 三角形 水
nature|drop.triangle.fill|水滴 三角形 水
nature|fish|魚
nature|fish.circle|魚 圓形
nature|fish.circle.fill|魚 圓形
nature|fish.fill|魚
nature|flame|火焰 火
nature|flame.circle|火焰 火 圓形
nature|flame.circle.fill|火焰 火 圓形
nature|flame.fill|火焰 火
nature|fossil.shell|化石
nature|fossil.shell.fill|化石
nature|globe.americas|地球
nature|globe.americas.fill|地球
nature|globe.asia.australia|地球
nature|globe.asia.australia.fill|地球
nature|globe.central.south.asia|地球
nature|globe.central.south.asia.fill|地球
nature|globe.europe.africa|地球
nature|globe.europe.africa.fill|地球
nature|humidity|水滴
nature|humidity.fill|水滴
nature|hurricane|
nature|hurricane.circle|圓形
nature|hurricane.circle.fill|圓形
nature|ladybug|瓢蟲 毛毛蟲
nature|ladybug.circle|瓢蟲 圓形 毛毛蟲
nature|ladybug.circle.fill|瓢蟲 圓形 毛毛蟲
nature|ladybug.fill|瓢蟲 毛毛蟲
nature|ladybug.slash|瓢蟲 正斜線 毛毛蟲
nature|ladybug.slash.circle|瓢蟲 正斜線 圓形 毛毛蟲
nature|ladybug.slash.circle.fill|瓢蟲 正斜線 圓形 毛毛蟲
nature|ladybug.slash.fill|瓢蟲 正斜線 毛毛蟲
nature|laurel.leading|
nature|laurel.trailing|
nature|leaf|葉子
nature|leaf.circle|葉子 圓形
nature|leaf.circle.fill|葉子 圓形
nature|leaf.fill|葉子
nature|lizard|蜥蜴
nature|lizard.circle|蜥蜴 圓形
nature|lizard.circle.fill|蜥蜴 圓形
nature|lizard.fill|蜥蜴
nature|moon|月亮
nature|moon.circle|月亮 圓形
nature|moon.circle.fill|月亮 圓形
nature|moon.dust|月亮
nature|moon.dust.circle|月亮 圓形
nature|moon.dust.circle.fill|月亮 圓形
nature|moon.dust.fill|月亮
nature|moon.fill|月亮
nature|moon.haze|月亮
nature|moon.haze.circle|月亮 圓形
nature|moon.haze.circle.fill|月亮 圓形
nature|moon.haze.fill|月亮
nature|moon.stars|月亮 星星 星
nature|moon.stars.circle|月亮 星星 星 圓形
nature|moon.stars.circle.fill|月亮 星星 星 圓形
nature|moon.stars.fill|月亮 星星 星
nature|moonphase.first.quarter|
nature|moonphase.first.quarter.inverse|
nature|moonphase.full.moon|月亮
nature|moonphase.full.moon.inverse|月亮
nature|moonphase.last.quarter|
nature|moonphase.last.quarter.inverse|
nature|moonphase.new.moon|月亮
nature|moonphase.new.moon.inverse|月亮
nature|moonphase.waning.crescent|
nature|moonphase.waning.crescent.inverse|
nature|moonphase.waning.gibbous|
nature|moonphase.waning.gibbous.inverse|
nature|moonphase.waxing.crescent|
nature|moonphase.waxing.crescent.inverse|
nature|moonphase.waxing.gibbous|
nature|moonphase.waxing.gibbous.inverse|
nature|mountain.2|山 露營
nature|mountain.2.circle|山 圓形 露營
nature|mountain.2.circle.fill|山 圓形 露營
nature|mountain.2.fill|山 露營
nature|pawprint|腳印 寵物
nature|pawprint.circle|腳印 寵物 圓形
nature|pawprint.circle.fill|腳印 寵物 圓形
nature|pawprint.fill|腳印 寵物
nature|rainbow|彩虹
nature|smoke|
nature|smoke.circle|圓形
nature|smoke.circle.fill|圓形
nature|smoke.fill|
nature|sparkles|閃亮 星光
nature|sun.dust|太陽
nature|sun.dust.circle|太陽 圓形
nature|sun.dust.circle.fill|太陽 圓形
nature|sun.dust.fill|太陽
nature|sun.haze|太陽
nature|sun.haze.circle|太陽 圓形
nature|sun.haze.circle.fill|太陽 圓形
nature|sun.haze.fill|太陽
nature|sun.horizon|太陽
nature|sun.horizon.circle|太陽 圓形
nature|sun.horizon.circle.fill|太陽 圓形
nature|sun.horizon.fill|太陽
nature|sun.max.trianglebadge.exclamationmark|太陽 驚嘆號 警告
nature|sun.max.trianglebadge.exclamationmark.fill|太陽 驚嘆號 警告
nature|sun.rain|太陽 雨
nature|sun.rain.circle|太陽 雨 圓形
nature|sun.rain.circle.fill|太陽 雨 圓形
nature|sun.rain.fill|太陽 雨
nature|sun.snow|太陽 雪
nature|sun.snow.circle|太陽 雪 圓形
nature|sun.snow.circle.fill|太陽 雪 圓形
nature|sun.snow.fill|太陽 雪
nature|sunrise|日出 箭頭
nature|sunrise.circle|日出 圓形 箭頭
nature|sunrise.circle.fill|日出 圓形 箭頭
nature|sunrise.fill|日出 箭頭
nature|sunset|日落 箭頭
nature|sunset.circle|日落 圓形 箭頭
nature|sunset.circle.fill|日落 圓形
nature|sunset.fill|日落 箭頭
nature|thermometer.snowflake|溫度計 溫度 雪花
nature|thermometer.snowflake.circle|溫度計 溫度 雪花 圓形
nature|thermometer.snowflake.circle.fill|溫度計 溫度 雪花 圓形
nature|thermometer.sun|溫度計 溫度 太陽
nature|thermometer.sun.circle|溫度計 溫度 太陽 圓形
nature|thermometer.sun.circle.fill|溫度計 溫度 太陽 圓形
nature|thermometer.sun.fill|溫度計 溫度 太陽
nature|tornado|龍捲風
nature|tornado.circle|龍捲風 圓形
nature|tornado.circle.fill|龍捲風 圓形
nature|tree|樹 露營
nature|tree.circle|樹 圓形 露營
nature|tree.circle.fill|樹 圓形 露營
nature|tree.fill|樹 露營
nature|tropicalstorm|
nature|tropicalstorm.circle|圓形
nature|tropicalstorm.circle.fill|圓形
nature|wind|風
nature|wind.circle|風 圓形
nature|wind.circle.fill|風 圓形
nature|wind.snow|風 雪
nature|wind.snow.circle|風 雪 圓形
nature|wind.snow.circle.fill|風 雪 圓形
connectivity|antenna.radiowaves.left.and.right|左 右
connectivity|antenna.radiowaves.left.and.right.circle|左 右 圓形
connectivity|antenna.radiowaves.left.and.right.circle.fill|左 右 圓形
connectivity|antenna.radiowaves.left.and.right.slash|左 右 正斜線
connectivity|antenna.radiowaves.left.and.right.slash.circle|左 右 正斜線 圓形
connectivity|antenna.radiowaves.left.and.right.slash.circle.fill|左 右 正斜線 圓形
connectivity|bolt.horizontal|閃電
connectivity|bolt.horizontal.circle|閃電 圓形
connectivity|bolt.horizontal.circle.fill|閃電 圓形
connectivity|bolt.horizontal.fill|閃電
connectivity|cellularbars|
connectivity|cellularbars.circle|圓形
connectivity|cellularbars.circle.fill|圓形
connectivity|cellularbars.short.cellularbars|
connectivity|dot.radiowaves.forward|快轉 右
connectivity|dot.radiowaves.left.and.right|左 右 收音機 車站
connectivity|dot.radiowaves.right|右
connectivity|dot.radiowaves.up.forward|上 快轉
connectivity|externaldrive.connected.to.line.below|外接硬碟
connectivity|externaldrive.connected.to.line.below.fill|外接硬碟
connectivity|network|
connectivity|network.badge.shield.half.filled|盾牌
connectivity|network.slash|正斜線
connectivity|personalhotspot|
connectivity|personalhotspot.circle|圓形
connectivity|personalhotspot.circle.fill|圓形
connectivity|personalhotspot.slash|正斜線
connectivity|sos|
connectivity|sos.circle|圓形
connectivity|sos.circle.fill|圓形
connectivity|wave.3.backward|倒轉 左
connectivity|wave.3.backward.circle|倒轉 圓形 左
connectivity|wave.3.backward.circle.fill|倒轉 圓形 左
connectivity|wave.3.down|下
connectivity|wave.3.down.circle|下 圓形
connectivity|wave.3.down.circle.fill|下 圓形
connectivity|wave.3.forward|快轉 右
connectivity|wave.3.forward.circle|快轉 圓形 右
connectivity|wave.3.forward.circle.fill|快轉 圓形 右
connectivity|wave.3.left|左
connectivity|wave.3.left.circle|左 圓形
connectivity|wave.3.left.circle.fill|左 圓形
connectivity|wave.3.right|右
connectivity|wave.3.right.circle|右 圓形
connectivity|wave.3.right.circle.fill|右 圓形
connectivity|wave.3.up|上
connectivity|wave.3.up.circle|上 圓形
connectivity|wave.3.up.circle.fill|上 圓形
connectivity|wifi|無線網路
connectivity|wifi.badge.lock|無線網路 鎖 鎖定
connectivity|wifi.circle|無線網路 圓形
connectivity|wifi.circle.fill|無線網路 圓形
connectivity|wifi.exclamationmark|無線網路 驚嘆號 警告
connectivity|wifi.exclamationmark.circle|無線網路 驚嘆號 警告 圓形
connectivity|wifi.exclamationmark.circle.fill|無線網路 驚嘆號 警告 圓形
connectivity|wifi.slash|無線網路 正斜線
connectivity|wifi.square|無線網路 方形
connectivity|wifi.square.fill|無線網路 方形
shapes|app|
shapes|app.fill|
shapes|capsule|
shapes|capsule.fill|
shapes|capsule.portrait|
shapes|capsule.portrait.fill|
shapes|circle|圓形
shapes|circle.fill|圓形
shapes|diamond|
shapes|diamond.fill|
shapes|hexagon|
shapes|hexagon.fill|
shapes|octagon|
shapes|octagon.fill|
shapes|oval|
shapes|oval.fill|
shapes|oval.portrait|
shapes|oval.portrait.fill|
shapes|pentagon|
shapes|pentagon.fill|
shapes|rectangle|長方形
shapes|rectangle.fill|長方形
shapes|rectangle.portrait|長方形
shapes|rectangle.portrait.fill|長方形
shapes|rhombus|
shapes|rhombus.fill|
shapes|square|方形
shapes|square.fill|方形
shapes|star.hexagon|星星 星
shapes|star.hexagon.fill|星星 星
shapes|triangle|三角形
shapes|triangle.fill|三角形
shapes|triangleshape|
shapes|triangleshape.fill|
shapes|viewfinder|
maps|app.connected.to.app.below.fill|
maps|base.unit|
maps|bicycle|腳踏車 單車
maps|bicycle.circle|腳踏車 單車 圓形
maps|bicycle.circle.fill|腳踏車 單車 圓形
maps|binoculars|望遠鏡
maps|binoculars.circle|望遠鏡 圓形
maps|binoculars.circle.fill|望遠鏡 圓形
maps|binoculars.fill|望遠鏡
maps|bus|公車
maps|bus.doubledecker|公車
maps|bus.doubledecker.fill|公車
maps|bus.fill|公車
maps|checkmark.circle.badge.airplane|勾 勾選 圓形 飛機
maps|checkmark.circle.badge.airplane.fill|勾 勾選 圓形 飛機
maps|map|地圖
maps|map.circle|地圖 圓形
maps|map.circle.fill|地圖 圓形
maps|map.fill|地圖
maps|mappin|地點 圖釘
maps|mappin.and.ellipse|地點 圖釘
maps|mappin.and.ellipse.circle|地點 圖釘 圓形
maps|mappin.and.ellipse.circle.fill|地點 圖釘 圓形
maps|mappin.circle|地點 圖釘 圓形
maps|mappin.circle.fill|地點 圖釘 圓形
maps|mappin.slash|地點 圖釘 正斜線
maps|mappin.slash.circle|地點 圖釘 正斜線 圓形
maps|mappin.slash.circle.fill|地點 圖釘 正斜線 圓形
maps|mappin.square|地點 圖釘 方形
maps|mappin.square.fill|地點 圖釘 方形
maps|point.bottomleft.filled.forward.to.point.topright.scurvepath|快轉
maps|point.bottomleft.forward.to.arrow.triangle.scurvepath|快轉 箭頭 三角形
maps|point.bottomleft.forward.to.arrow.triangle.scurvepath.fill|快轉 箭頭 三角形
maps|point.bottomleft.forward.to.arrow.triangle.uturn.scurvepath|快轉 箭頭 三角形
maps|point.bottomleft.forward.to.arrow.triangle.uturn.scurvepath.fill|快轉 箭頭 三角形
maps|point.bottomleft.forward.to.point.topright.filled.scurvepath|快轉
maps|point.bottomleft.forward.to.point.topright.scurvepath|快轉
maps|point.bottomleft.forward.to.point.topright.scurvepath.fill|快轉
maps|point.forward.to.point.capsulepath|快轉
maps|point.forward.to.point.capsulepath.fill|快轉
maps|point.topleft.down.to.point.bottomright.curvepath|下
maps|point.topleft.down.to.point.bottomright.curvepath.fill|下
maps|point.topleft.down.to.point.bottomright.filled.curvepath|下
maps|point.topleft.filled.down.to.point.bottomright.curvepath|下
maps|point.topright.arrow.triangle.backward.to.point.bottomleft.filled.scurvepath|箭頭 三角形 倒轉
maps|point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath|箭頭 三角形 倒轉
maps|point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath.fill|箭頭 三角形 倒轉
maps|point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath|箭頭 三角形 倒轉
maps|tram|電車
maps|tram.circle|電車 圓形
maps|tram.fill|電車
weather|aqi.high|警告
weather|aqi.low|
weather|aqi.medium|
weather|degreesign.celsius|
weather|degreesign.fahrenheit|
weather|thermometer.high|溫度計 溫度
weather|thermometer.low|溫度計 溫度
weather|thermometer.medium|溫度計 溫度
weather|thermometer.medium.slash|溫度計 溫度 正斜線
textformatting|arrow.left.and.right.text.vertical|箭頭 左 右
textformatting|arrow.up.and.down.text.horizontal|箭頭 上 下
textformatting|bold|
textformatting|bold.italic.underline|
textformatting|bold.underline|
textformatting|character|
textformatting|character.circle|圓形
textformatting|character.circle.fill|圓形
textformatting|character.circle.fill.mni|圓形
textformatting|character.circle.mni|圓形
textformatting|character.cursor.ibeam|
textformatting|character.mni|
textformatting|character.phonetic|
textformatting|character.square|方形
textformatting|character.square.fill|方形
textformatting|character.square.fill.mni|方形
textformatting|character.square.mni|方形
textformatting|character.sutton|
textformatting|character.text.justify|
textformatting|character.text.justify.mni|
textformatting|character.textbox|
textformatting|character.textbox.badge.sparkles|閃亮 星光
textformatting|character.textbox.badge.sparkles.mni|閃亮 星光
textformatting|character.textbox.mni|
textformatting|characters.lowercase|
textformatting|characters.uppercase|
textformatting|checklist|
textformatting|checklist.checked|
textformatting|checklist.unchecked|
textformatting|decrease.indent|
textformatting|decrease.quotelevel|
textformatting|fleuron|
textformatting|fleuron.fill|
textformatting|increase.indent|
textformatting|increase.quotelevel|
textformatting|italic|
textformatting|kashida.arabic|
textformatting|list.bullet|清單 項目號
textformatting|list.bullet.badge.ellipsis|清單 項目號 省略號
textformatting|list.bullet.circle|清單 項目號 圓形
textformatting|list.bullet.circle.fill|清單 項目號 圓形
textformatting|list.bullet.indent|清單 項目號
textformatting|list.dash|清單
textformatting|list.dash.badge.ellipsis|清單 省略號
textformatting|list.number|清單
textformatting|list.number.badge.ellipsis|清單 省略號
textformatting|list.star|清單 星星 星
textformatting|list.triangle|清單 三角形
textformatting|numbers|
textformatting|numbers.mni|
textformatting|numbers.rectangle|長方形
textformatting|numbers.rectangle.fill|長方形
textformatting|numero.sign|
textformatting|paragraphsign|
textformatting|quotelevel|
textformatting|shadow|
textformatting|square.fill.text.grid.1x2|方形 格狀
textformatting|strikethrough|
textformatting|strikethrough.double|
textformatting|text.aligncenter|
textformatting|text.alignleft|
textformatting|text.alignright|
textformatting|text.justify|
textformatting|text.justify.leading|
textformatting|text.justify.left|左
textformatting|text.justify.right|右
textformatting|text.justify.trailing|
textformatting|text.line.magnify|
textformatting|text.redaction|
textformatting|text.square.filled|方形
textformatting|text.word.spacing|
textformatting|textformat|
textformatting|textformat.alt|
textformatting|textformat.alt.mni|
textformatting|textformat.characters|
textformatting|textformat.characters.arrow.left.and.right|箭頭 左 右
textformatting|textformat.characters.arrow.left.and.right.mni|箭頭 左 右
textformatting|textformat.characters.dottedunderline|
textformatting|textformat.characters.dottedunderline.mni|
textformatting|textformat.characters.mni|
textformatting|textformat.mni|
textformatting|textformat.numbers|
textformatting|textformat.numbers.mni|
textformatting|textformat.subscript|
textformatting|textformat.subscript.mni|
textformatting|textformat.superscript|
textformatting|textformat.superscript.mni|
textformatting|underline|
textformatting|underline.double|
cameraandphotos|arrow.trianglehead.2.clockwise.rotate.90.camera|箭頭 相機 拍照
cameraandphotos|arrow.trianglehead.2.clockwise.rotate.90.camera.fill|箭頭 相機 拍照
cameraandphotos|arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right|箭頭 左 右
cameraandphotos|arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right.fill|箭頭 左 右
cameraandphotos|arrow.trianglehead.up.and.down.righttriangle.up.righttriangle.down|箭頭 上 下
cameraandphotos|arrow.trianglehead.up.and.down.righttriangle.up.righttriangle.down.fill|箭頭 上 下
cameraandphotos|bolt|閃電 相機 拍照
cameraandphotos|bolt.badge.automatic|閃電 相機 拍照
cameraandphotos|bolt.badge.automatic.fill|閃電 相機 拍照
cameraandphotos|bolt.badge.checkmark|閃電 勾 勾選
cameraandphotos|bolt.badge.checkmark.fill|閃電 勾 勾選
cameraandphotos|bolt.badge.clock|閃電 時鐘 時間
cameraandphotos|bolt.badge.clock.fill|閃電 時鐘 時間
cameraandphotos|bolt.badge.xmark|閃電 叉 關閉
cameraandphotos|bolt.badge.xmark.fill|閃電 叉 關閉
cameraandphotos|bolt.circle|閃電 圓形 相機 拍照
cameraandphotos|bolt.circle.fill|閃電 圓形 相機 拍照
cameraandphotos|bolt.fill|閃電 相機 拍照
cameraandphotos|bolt.slash|閃電 正斜線 相機 拍照
cameraandphotos|bolt.slash.circle|閃電 正斜線 圓形 相機 拍照
cameraandphotos|bolt.slash.circle.fill|閃電 正斜線 圓形 相機 拍照
cameraandphotos|bolt.slash.fill|閃電 正斜線 相機 拍照
cameraandphotos|bolt.square|閃電 方形 相機 拍照
cameraandphotos|bolt.square.fill|閃電 方形 相機 拍照
cameraandphotos|bolt.trianglebadge.exclamationmark|閃電 驚嘆號 警告
cameraandphotos|bolt.trianglebadge.exclamationmark.fill|閃電 驚嘆號 警告
cameraandphotos|camera|相機 拍照
cameraandphotos|camera.aperture|相機 拍照
cameraandphotos|camera.badge.clock|相機 拍照 時鐘 時間
cameraandphotos|camera.badge.clock.fill|相機 拍照 時鐘 時間
cameraandphotos|camera.badge.ellipsis|相機 拍照 省略號
cameraandphotos|camera.badge.ellipsis.fill|相機 拍照 省略號
cameraandphotos|camera.circle|相機 拍照 圓形
cameraandphotos|camera.circle.fill|相機 拍照 圓形
cameraandphotos|camera.fill|相機 拍照
cameraandphotos|camera.filters|相機 拍照
cameraandphotos|camera.macro|相機 拍照
cameraandphotos|camera.macro.circle|相機 拍照 圓形
cameraandphotos|camera.macro.circle.fill|相機 拍照 圓形
cameraandphotos|camera.macro.slash|相機 拍照 正斜線
cameraandphotos|camera.macro.slash.circle|相機 拍照 正斜線 圓形
cameraandphotos|camera.macro.slash.circle.fill|相機 拍照 正斜線 圓形
cameraandphotos|camera.metering.center.weighted|相機 拍照
cameraandphotos|camera.metering.center.weighted.average|相機 拍照
cameraandphotos|camera.metering.matrix|相機 拍照
cameraandphotos|camera.metering.multispot|相機 拍照
cameraandphotos|camera.metering.none|相機 拍照
cameraandphotos|camera.metering.partial|相機 拍照
cameraandphotos|camera.metering.spot|相機 拍照
cameraandphotos|camera.metering.unknown|相機 拍照
cameraandphotos|camera.on.rectangle|相機 拍照 長方形
cameraandphotos|camera.on.rectangle.fill|相機 拍照 長方形
cameraandphotos|camera.shutter.button|相機 拍照
cameraandphotos|camera.shutter.button.fill|相機 拍照
cameraandphotos|camera.viewfinder|相機 拍照
cameraandphotos|camera.viewfinder.badge.automatic|相機 拍照
cameraandphotos|circle.and.line.horizontal|圓形
cameraandphotos|circle.and.line.horizontal.fill|圓形
cameraandphotos|circle.bottomrighthalf.pattern.checkered|圓形
cameraandphotos|circle.dashed.rectangle|圓形 長方形
cameraandphotos|circle.dotted.and.circle|圓形
cameraandphotos|circle.dotted.circle|圓形
cameraandphotos|circle.dotted.circle.fill|圓形
cameraandphotos|circle.filled.pattern.diagonalline.rectangle|圓形 長方形
cameraandphotos|circle.lefthalf.filled.righthalf.striped.horizontal|圓形
cameraandphotos|circle.lefthalf.filled.righthalf.striped.horizontal.inverse|圓形
cameraandphotos|circle.lefthalf.striped.horizontal|圓形
cameraandphotos|circle.lefthalf.striped.horizontal.inverse|圓形
cameraandphotos|circle.rectangle.dashed|圓形 長方形
cameraandphotos|circle.rectangle.filled.pattern.diagonalline|圓形 長方形
cameraandphotos|dot.scope|圓形 目標
cameraandphotos|drop.halffull|水滴
cameraandphotos|f.cursive|
cameraandphotos|f.cursive.circle|圓形
cameraandphotos|f.cursive.circle.fill|圓形
cameraandphotos|f.cursive.slash|正斜線
cameraandphotos|ipad.rear.camera|平板 相機 拍照
cameraandphotos|iphone.rear.camera|手機 相機 拍照
cameraandphotos|light.tube.rays|
cameraandphotos|lightspectrum.horizontal|
cameraandphotos|perspective|
cameraandphotos|photo|照片 相片 山 太陽
cameraandphotos|photo.badge.arrow.down|照片 相片 箭頭 下 山 太陽
cameraandphotos|photo.badge.arrow.down.fill|照片 相片 箭頭 下 山 太陽
cameraandphotos|photo.badge.checkmark|照片 相片 勾 勾選 山 太陽
cameraandphotos|photo.badge.checkmark.fill|照片 相片 勾 勾選 山 太陽
cameraandphotos|photo.badge.exclamationmark|照片 相片 驚嘆號 警告 山 太陽
cameraandphotos|photo.badge.exclamationmark.fill|照片 相片 驚嘆號 警告 山 太陽
cameraandphotos|photo.badge.magnifyingglass|照片 相片 放大鏡 搜尋 山 太陽
cameraandphotos|photo.badge.magnifyingglass.fill|照片 相片 放大鏡 搜尋 山 太陽
cameraandphotos|photo.badge.plus|照片 相片 加號 新增 山 太陽
cameraandphotos|photo.badge.plus.fill|照片 相片 加號 新增 山 太陽
cameraandphotos|photo.badge.questionmark|照片 相片 問號 山 太陽
cameraandphotos|photo.badge.questionmark.fill|照片 相片 問號 山 太陽
cameraandphotos|photo.badge.shield.exclamationmark|照片 相片 盾牌 驚嘆號 警告 山 太陽
cameraandphotos|photo.badge.shield.exclamationmark.fill|照片 相片 盾牌 驚嘆號 警告 山 太陽
cameraandphotos|photo.circle|照片 相片 圓形 山 太陽
cameraandphotos|photo.circle.fill|照片 相片 圓形 山 太陽
cameraandphotos|photo.fill|照片 相片 山 太陽
cameraandphotos|photo.fill.on.rectangle.fill|照片 相片 長方形 山 太陽
cameraandphotos|photo.on.rectangle|照片 相片 長方形 山 太陽
cameraandphotos|photo.on.rectangle.angled|照片 相片 長方形 山 太陽
cameraandphotos|photo.on.rectangle.angled.fill|照片 相片 長方形 山 太陽
cameraandphotos|photo.slash|照片 相片 正斜線 山 太陽
cameraandphotos|photo.slash.fill|照片 相片 正斜線 山 太陽
cameraandphotos|photo.stack|照片 相片 山 太陽
cameraandphotos|photo.stack.fill|照片 相片 山 太陽
cameraandphotos|photo.trianglebadge.exclamationmark|照片 相片 驚嘆號 警告 山 太陽
cameraandphotos|photo.trianglebadge.exclamationmark.fill|照片 相片 驚嘆號 警告 山 太陽
cameraandphotos|plus.viewfinder|加號 新增
cameraandphotos|plusminus|
cameraandphotos|plusminus.circle|圓形
cameraandphotos|plusminus.circle.fill|圓形
cameraandphotos|rectangle.and.arrow.up.right.and.arrow.down.left|長方形 箭頭 上 右 下 左
cameraandphotos|rectangle.and.arrow.up.right.and.arrow.down.left.slash|長方形 箭頭 上 右 下 左 正斜線
cameraandphotos|rectangle.stack|長方形
cameraandphotos|rectangle.stack.fill|長方形
cameraandphotos|rectangle.stack.slash|長方形 正斜線
cameraandphotos|rectangle.stack.slash.fill|長方形 正斜線
cameraandphotos|righttriangle|
cameraandphotos|righttriangle.fill|
cameraandphotos|righttriangle.split.diagonal|
cameraandphotos|righttriangle.split.diagonal.fill|
cameraandphotos|scope|圓形 目標
cameraandphotos|scope.continuous|圓形 目標
cameraandphotos|square.2.layers.3d|方形
cameraandphotos|square.2.layers.3d.bottom.filled|方形
cameraandphotos|square.2.layers.3d.fill|方形
cameraandphotos|square.2.layers.3d.top.filled|方形
cameraandphotos|square.3.layers.3d|方形
cameraandphotos|square.3.layers.3d.bottom.filled|方形
cameraandphotos|square.3.layers.3d.down.backward|方形 下 倒轉
cameraandphotos|square.3.layers.3d.down.forward|方形 下 快轉
cameraandphotos|square.3.layers.3d.down.left|方形 下 左
cameraandphotos|square.3.layers.3d.down.left.slash|方形 下 左 正斜線
cameraandphotos|square.3.layers.3d.down.right|方形 下 右
cameraandphotos|square.3.layers.3d.down.right.slash|方形 下 右 正斜線
cameraandphotos|square.3.layers.3d.middle.filled|方形
cameraandphotos|square.3.layers.3d.slash|方形 正斜線
cameraandphotos|square.3.layers.3d.top.filled|方形
cameraandphotos|squareshape.on.pattern.diagonalline|
cameraandphotos|swirl.circle.righthalf.filled|圓形
cameraandphotos|swirl.circle.righthalf.filled.inverse|圓形
cameraandphotos|text.below.photo|照片 相片 山 太陽
cameraandphotos|text.below.photo.fill|照片 相片 山 太陽
cameraandphotos|trapezoid.and.line.horizontal|
cameraandphotos|trapezoid.and.line.horizontal.fill|
cameraandphotos|trapezoid.and.line.vertical|
cameraandphotos|trapezoid.and.line.vertical.fill|
cameraandphotos|viewfinder.and.person|人 人物 人們
media|arrow.trianglehead.rectanglepath|箭頭
media|backward|倒轉
media|backward.circle|倒轉 圓形
media|backward.circle.fill|倒轉 圓形
media|backward.end|倒轉
media|backward.end.alt|倒轉
media|backward.end.alt.fill|倒轉
media|backward.end.circle|倒轉 圓形
media|backward.end.circle.fill|倒轉 圓形
media|backward.end.fill|倒轉
media|backward.fill|倒轉
media|backward.frame|倒轉
media|backward.frame.fill|倒轉
media|forward|快轉
media|forward.circle|快轉 圓形
media|forward.circle.fill|快轉 圓形
media|forward.end|快轉
media|forward.end.alt|快轉
media|forward.end.alt.fill|快轉
media|forward.end.circle|快轉 圓形
media|forward.end.circle.fill|快轉 圓形
media|forward.end.fill|快轉
media|forward.fill|快轉
media|forward.frame|快轉
media|forward.frame.fill|快轉
media|house.badge.exclamationmark|房子 家 首頁 驚嘆號 警告
media|house.badge.exclamationmark.fill|房子 家 首頁 驚嘆號 警告
media|infinity|無限大
media|infinity.circle|無限大 圓形
media|infinity.circle.fill|無限大 圓形
media|music.note.house|音樂 音符 備註 房子 家 首頁
media|music.note.house.fill|音樂 音符 備註 房子 家 首頁
media|pause|暫停
media|pause.circle|暫停 圓形
media|pause.circle.fill|暫停 圓形
media|pause.fill|暫停
media|pause.rectangle|暫停 長方形
media|pause.rectangle.fill|暫停 長方形
media|play|播放
media|play.circle|播放 圓形
media|play.circle.fill|播放 圓形
media|play.diamond|播放
media|play.diamond.fill|播放
media|play.fill|播放
media|play.house|播放 房子 家 首頁
media|play.house.fill|播放 房子 家 首頁
media|play.rectangle|播放 長方形
media|play.rectangle.fill|播放 長方形
media|play.slash|播放 正斜線
media|play.slash.fill|播放 正斜線
media|play.square|播放 方形
media|play.square.fill|播放 方形
media|play.square.stack|播放 方形
media|play.square.stack.fill|播放 方形
media|playpause|
media|playpause.circle|圓形
media|playpause.circle.fill|圓形
media|playpause.fill|
media|record.circle|圓形
media|record.circle.fill|圓形
media|stop|停止
media|stop.circle|停止 圓形
media|stop.circle.fill|停止 圓形
media|stop.fill|停止
media|text.line.first.and.arrowtriangle.forward|快轉
media|text.line.last.and.arrowtriangle.forward|快轉
accessibility|arrow.up.and.down.and.arrow.left.and.right|箭頭 上 下 左 右
accessibility|arrow.up.and.down.and.sparkles|箭頭 上 下 閃亮 星光
accessibility|arrow.up.left.and.down.right.and.arrow.up.right.and.down.left|箭頭 上 左 下 右
accessibility|captions.bubble|
accessibility|captions.bubble.fill|
accessibility|character.duployan|
accessibility|character.magnify|
accessibility|character.magnify.mni|
accessibility|circle.hexagonpath|圓形
accessibility|circle.hexagonpath.fill|圓形
accessibility|contextualmenu.and.pointer.arrow|箭頭
accessibility|dot.arrowtriangles.up.right.down.left.circle|上 右 下 左 圓形
accessibility|dot.circle.and.hand.point.up.left.fill|圓形 手 上 左
accessibility|dot.circle.and.pointer.arrow|圓形 箭頭
accessibility|ear|耳朵
accessibility|ear.badge.checkmark|耳朵 勾 勾選
accessibility|ear.badge.waveform|耳朵
accessibility|ear.fill|耳朵
accessibility|ear.trianglebadge.exclamationmark|耳朵 驚嘆號 警告
accessibility|ellipsis.bubble|省略號
accessibility|ellipsis.bubble.fill|省略號
accessibility|eye|眼睛
accessibility|eye.circle|眼睛 圓形
accessibility|eye.circle.fill|眼睛 圓形
accessibility|eye.fill|眼睛
accessibility|eye.half.closed|眼睛
accessibility|eye.half.closed.fill|眼睛
accessibility|eye.slash|眼睛 正斜線
accessibility|eye.slash.circle|眼睛 正斜線 圓形
accessibility|eye.slash.circle.fill|眼睛 正斜線 圓形
accessibility|eye.slash.fill|眼睛 正斜線
accessibility|eye.square|眼睛 方形
accessibility|eye.square.fill|眼睛 方形
accessibility|eye.trianglebadge.exclamationmark|眼睛 驚嘆號 警告
accessibility|eye.trianglebadge.exclamationmark.fill|眼睛 驚嘆號 警告
accessibility|figure|人形 人 人物
accessibility|figure.2|人形 人 人物
accessibility|figure.2.circle|人形 圓形 人 人物
accessibility|figure.2.circle.fill|人形 圓形 人 人物
accessibility|figure.roll|人形 人 人物
accessibility|figure.roll.circle|人形 圓形 人 人物
accessibility|figure.roll.circle.fill|人形 圓形 人 人物
accessibility|figure.roll.runningpace|人形 人 人物
accessibility|figure.roll.runningpace.circle|人形 圓形 人 人物
accessibility|figure.roll.runningpace.circle.fill|人形 圓形 人 人物
accessibility|figure.stand.line.dotted.figure.stand|人形 人 人物
accessibility|filemenu.and.pointer.arrow|箭頭
accessibility|hand.point.up|手 上
accessibility|hand.point.up.braille|手 上
accessibility|hand.point.up.braille.badge.ellipsis|手 上 省略號
accessibility|hand.point.up.braille.badge.ellipsis.fill|手 上 省略號
accessibility|hand.point.up.braille.fill|手 上
accessibility|hand.point.up.fill|手 上
accessibility|hand.rays|手
accessibility|hand.rays.fill|手
accessibility|hand.tap|手
accessibility|hand.tap.fill|手
accessibility|hare|兔子
accessibility|hare.circle|兔子 圓形
accessibility|hare.circle.fill|兔子 圓形
accessibility|hare.fill|兔子
accessibility|hearingdevice.and.signal.meter|耳朵
accessibility|hearingdevice.and.signal.meter.fill|耳朵
accessibility|hearingdevice.ear|耳朵
accessibility|hearingdevice.ear.fill|耳朵
accessibility|minus.magnifyingglass|減號 放大鏡 搜尋
accessibility|plus.magnifyingglass|加號 新增 放大鏡 搜尋
accessibility|pointer.arrow.and.square.on.square.dashed|箭頭 方形
accessibility|pointer.arrow.click|箭頭
accessibility|pointer.arrow.click.2|箭頭
accessibility|pointer.arrow.click.badge.clock|箭頭 時鐘 時間
accessibility|pointer.arrow.ipad.and.square.on.square.dashed|箭頭 平板 方形
accessibility|pointer.arrow.ipad.rays|箭頭 平板
accessibility|pointer.arrow.motionlines|箭頭
accessibility|pointer.arrow.motionlines.click|箭頭
accessibility|pointer.arrow.rays|箭頭
accessibility|quote.bubble|
accessibility|quote.bubble.fill|
accessibility|rectangle.3.group.bubble|長方形
accessibility|rectangle.3.group.bubble.fill|長方形
accessibility|rectangle.and.text.magnifyingglass|長方形 放大鏡 搜尋
accessibility|service.dog|狗
accessibility|service.dog.fill|狗
accessibility|smallcircle.filled.circle|圓形
accessibility|smallcircle.filled.circle.fill|圓形
accessibility|square.grid.3x3.bottomleft.filled|方形 格狀
accessibility|square.grid.3x3.bottommiddle.filled|方形 格狀
accessibility|square.grid.3x3.bottomright.filled|方形 格狀
accessibility|square.grid.3x3.middle.filled|方形 格狀
accessibility|square.grid.3x3.middleleft.filled|方形 格狀
accessibility|square.grid.3x3.middleright.filled|方形 格狀
accessibility|square.grid.3x3.topleft.filled|方形 格狀
accessibility|square.grid.3x3.topmiddle.filled|方形 格狀
accessibility|square.grid.3x3.topright.filled|方形 格狀
accessibility|textformat.size|
accessibility|textformat.size.larger|
accessibility|textformat.size.larger.mni|
accessibility|textformat.size.mni|
accessibility|textformat.size.smaller|
accessibility|textformat.size.smaller.mni|
accessibility|tortoise|烏龜
accessibility|tortoise.circle|烏龜 圓形
accessibility|tortoise.circle.fill|烏龜 圓形
accessibility|tortoise.fill|烏龜
accessibility|waveform.badge.magnifyingglass|放大鏡 搜尋
accessibility|wheelchair|
accessibility|xmark.triangle.circle.square|叉 關閉 三角形 圓形 方形
accessibility|xmark.triangle.circle.square.fill|叉 關閉 三角形 圓形 方形
human|arrow.up.and.person.rectangle.portrait|箭頭 上 人 人物 長方形 人們
human|arrow.up.and.person.rectangle.turn.left|箭頭 上 人 人物 長方形 左 人們
human|arrow.up.and.person.rectangle.turn.right|箭頭 上 人 人物 長方形 右 人們
human|calendar.and.person|日曆 日期 人 人物
human|externaldrive.badge.person.crop|外接硬碟 人 人物
human|externaldrive.fill.badge.person.crop|外接硬碟 人 人物
human|eyebrow|
human|eyes|雙眼
human|eyes.inverse|雙眼
human|face.dashed|臉
human|face.dashed.fill|臉
human|face.smiling|臉 微笑
human|face.smiling.inverse|臉 微笑
human|figure.2.and.child.holdinghands|人形 孩子 小孩 家庭 人 人物
human|figure.2.arms.open|人形 人 人物
human|figure.2.ascending|人形 孩子 小孩 家庭 人 人物
human|figure.2.descending|人形 孩子 小孩 家庭 人 人物
human|figure.2.left.holdinghands|人形 左 人 人物
human|figure.2.right.holdinghands|人形 右 人 人物
human|figure.and.child.holdinghands|人形 孩子 小孩 家庭 人 人物
human|figure.arms.open|人形 人 人物
human|figure.child.shield|人形 孩子 小孩 盾牌
human|figure.child.shield.fill|人形 孩子 小孩 盾牌
human|figure.fall|人形 人 人物
human|figure.fall.circle|人形 圓形 人 人物
human|figure.fall.circle.fill|人形 圓形 人 人物
human|figure.seated.side.right.child.lap|人形 右 孩子 小孩 人 人物
human|figure.stand|人形 人 人物
human|figure.stand.and.figure.teen|人形 孩子 小孩 家庭 人 人物
human|figure.stand.dress|人形 洋裝 人 人物
human|figure.stand.dress.line.vertical.figure|人形 洋裝 人 人物
human|figure.teen|人形 人 人物
human|figure.teen.and.lock|人形 鎖 鎖定 人 人物
human|figure.teen.and.lock.fill|人形 鎖 鎖定 人 人物
human|figure.teen.and.lock.open|人形 鎖 鎖定 人 人物
human|figure.teen.and.lock.open.fill|人形 鎖 鎖定 人 人物
human|figure.teen.shield|人形 盾牌
human|figure.teen.shield.fill|人形 盾牌
human|figure.walk.suitcase.rolling|人形 走路 行李箱 旅行 人 人物
human|figure.walk.suitcase.rolling.circle|人形 走路 行李箱 旅行 圓形 人 人物
human|figure.walk.suitcase.rolling.circle.fill|人形 走路 行李箱 旅行 圓形 人 人物
human|figure.walk.triangle|人形 走路 三角形 人 人物
human|figure.walk.triangle.fill|人形 走路 三角形 人 人物
human|figure.wave|人形 人 人物
human|figure.wave.circle|人形 圓形 人 人物
human|figure.wave.circle.fill|人形 圓形 人 人物
human|folder.and.person|資料夾 人 人物
human|folder.and.person.fill|資料夾 人 人物
human|folder.badge.person.crop|資料夾 人 人物
human|folder.fill.badge.person.crop|資料夾 人 人物
human|globe.and.person|地球 人 人物
human|hand.draw|手
human|hand.draw.badge.ellipsis|手 省略號
human|hand.draw.badge.ellipsis.fill|手 省略號
human|hand.draw.fill|手
human|hand.palm.facing|手
human|hand.palm.facing.fill|手
human|hand.pinch|手
human|hand.pinch.fill|手
human|hand.point.down|手 下
human|hand.point.down.fill|手 下
human|hand.point.left|手 左
human|hand.point.left.fill|手 左
human|hand.point.right|手 右
human|hand.point.right.fill|手 右
human|hand.point.up.left|手 上 左
human|hand.point.up.left.and.text|手 上 左
human|hand.point.up.left.and.text.fill|手 上 左
human|hand.point.up.left.fill|手 上 左
human|hand.raised|手
human|hand.raised.app|手
human|hand.raised.app.fill|手
human|hand.raised.circle|手 圓形
human|hand.raised.circle.fill|手 圓形
human|hand.raised.fill|手
human|hand.raised.fingers.spread|手
human|hand.raised.fingers.spread.fill|手
human|hand.raised.palm.facing|手
human|hand.raised.palm.facing.fill|手
human|hand.raised.slash|手 正斜線
human|hand.raised.slash.fill|手 正斜線
human|hand.raised.square|手 方形
human|hand.raised.square.fill|手 方形
human|hand.thumbsdown|手
human|hand.thumbsdown.circle|手 圓形
human|hand.thumbsdown.circle.fill|手 圓形
human|hand.thumbsdown.fill|手
human|hand.thumbsdown.filled.hand.thumbsup|手 讚 大拇指
human|hand.thumbsdown.hand.thumbsup|手 讚 大拇指
human|hand.thumbsdown.hand.thumbsup.fill|手 讚 大拇指
human|hand.thumbsdown.hand.thumbsup.filled|手 讚 大拇指
human|hand.thumbsdown.slash|手 正斜線
human|hand.thumbsdown.slash.fill|手 正斜線
human|hand.thumbsup|手 讚 大拇指
human|hand.thumbsup.circle|手 讚 大拇指 圓形
human|hand.thumbsup.circle.fill|手 讚 大拇指 圓形
human|hand.thumbsup.fill|手 讚 大拇指
human|hand.thumbsup.slash|手 讚 大拇指 正斜線
human|hand.thumbsup.slash.fill|手 讚 大拇指 正斜線
human|hand.wave|手
human|hand.wave.fill|手
human|hands.and.sparkles|手 閃亮 星光
human|hands.and.sparkles.fill|手 閃亮 星光
human|hands.clap|手
human|hands.clap.fill|手
human|inset.filled.rectangle.and.person|長方形 人 人物 人們
human|inset.filled.rectangle.and.person.filled.circle|長方形 人 人物 圓形 人們
human|inset.filled.rectangle.and.person.filled.circle.fill|長方形 人 人物 圓形 人們
human|inset.filled.rectangle.and.person.slash|長方形 人 人物 正斜線 人們
human|inset.filled.rectangle.and.pointer.arrow|長方形 箭頭
human|inset.filled.rectangle.badge.record|長方形
human|mouth|嘴巴
human|mouth.fill|嘴巴
human|mustache|
human|mustache.fill|
human|nose|鼻子
human|nose.fill|鼻子
human|person|人 人物 人們
human|person.2|人 人物 人們
human|person.2.badge|人 人物 人們
human|person.2.badge.fill|人 人物 人們
human|person.2.badge.gearshape|人 人物 設定 齒輪 人們
human|person.2.badge.gearshape.fill|人 人物 設定 齒輪 人們
human|person.2.badge.minus|人 人物 減號 人們
human|person.2.badge.minus.fill|人 人物 減號 人們
human|person.2.badge.plus|人 人物 加號 新增 人們
human|person.2.badge.plus.fill|人 人物 加號 新增 人們
human|person.2.circle|人 人物 圓形 人們
human|person.2.circle.fill|人 人物 圓形 人們
human|person.2.crop.square.stack|人 人物 方形 人們
human|person.2.crop.square.stack.fill|人 人物 方形 人們
human|person.2.fill|人 人物 人們
human|person.2.shield|人 人物 盾牌 人們
human|person.2.shield.fill|人 人物 盾牌 人們
human|person.2.slash|人 人物 正斜線 人們
human|person.2.slash.fill|人 人物 正斜線 人們
human|person.2.wave.2|人 人物 人們
human|person.2.wave.2.fill|人 人物 人們
human|person.3|人 人物 人們
human|person.3.fill|人 人物 人們
human|person.3.sequence|人 人物 人們
human|person.3.sequence.fill|人 人物 人們
human|person.and.arrow.left.and.arrow.right.outward|人 人物 箭頭 左 右 人們
human|person.and.background.dotted|人 人物 人們
human|person.and.background.striped.horizontal|人 人物
human|person.badge.checkmark|人 人物 勾 勾選 人們
human|person.badge.checkmark.fill|人 人物 勾 勾選 人們
human|person.badge.checkmark.seal|人 人物 勾 勾選 海豹 人們
human|person.badge.checkmark.seal.fill|人 人物 勾 勾選 海豹 人們
human|person.badge.clock|人 人物 時鐘 時間 人們
human|person.badge.clock.fill|人 人物 時鐘 時間 人們
human|person.badge.creditcard|人 人物 信用卡 人們
human|person.badge.creditcard.fill|人 人物 信用卡 人們
human|person.badge.gearshape|人 人物 設定 齒輪 人們
human|person.badge.gearshape.fill|人 人物 設定 齒輪 人們
human|person.badge.location|人 人物 位置 定位 人們
human|person.badge.location.fill|人 人物 位置 定位 人們
human|person.badge.minus|人 人物 減號 人們
human|person.badge.plus|人 人物 加號 新增 人們
human|person.badge.shield.checkmark|人 人物 盾牌 勾 勾選 人們
human|person.badge.shield.checkmark.fill|人 人物 盾牌 勾 勾選 人們
human|person.badge.shield.exclamationmark|人 人物 盾牌 驚嘆號 警告 人們
human|person.badge.shield.exclamationmark.fill|人 人物 盾牌 驚嘆號 警告 人們
human|person.bust|人 人物 人們
human|person.bust.circle|人 人物 圓形 人們
human|person.bust.circle.fill|人 人物 圓形 人們
human|person.bust.fill|人 人物 人們
human|person.checkmark.and.xmark|人 人物 勾 勾選 叉 關閉 人們
human|person.circle|人 人物 圓形 人們
human|person.circle.fill|人 人物 圓形 人們
human|person.crop.artframe|人 人物 人們
human|person.crop.circle|人 人物 圓形 人們
human|person.crop.circle.badge|人 人物 圓形 人們
human|person.crop.circle.badge.checkmark|人 人物 圓形 勾 勾選 人們
human|person.crop.circle.badge.clock|人 人物 圓形 時鐘 時間 人們
human|person.crop.circle.badge.clock.fill|人 人物 圓形 時鐘 時間 人們
human|person.crop.circle.badge.ellipsis|人 人物 圓形 省略號 人們
human|person.crop.circle.badge.ellipsis.fill|人 人物 圓形 省略號 人們
human|person.crop.circle.badge.exclamationmark|人 人物 圓形 驚嘆號 警告 人們
human|person.crop.circle.badge.exclamationmark.fill|人 人物 圓形 驚嘆號 警告 人們
human|person.crop.circle.badge.fill|人 人物 圓形 人們
human|person.crop.circle.badge.magnifyingglass|人 人物 圓形 放大鏡 搜尋 人們
human|person.crop.circle.badge.magnifyingglass.fill|人 人物 圓形 放大鏡 搜尋 人們
human|person.crop.circle.badge.minus|人 人物 圓形 減號 人們
human|person.crop.circle.badge.moon|人 人物 圓形 月亮 人們
human|person.crop.circle.badge.moon.fill|人 人物 圓形 月亮 人們
human|person.crop.circle.badge.plus|人 人物 圓形 加號 新增 人們
human|person.crop.circle.badge.questionmark|人 人物 圓形 問號 人們
human|person.crop.circle.badge.questionmark.fill|人 人物 圓形 問號 人們
human|person.crop.circle.badge.xmark|人 人物 圓形 叉 關閉 人們
human|person.crop.circle.dashed|人 人物 圓形 人們
human|person.crop.circle.dashed.circle|人 人物 圓形 人們
human|person.crop.circle.dashed.circle.fill|人 人物 圓形 人們
human|person.crop.circle.fill|人 人物 圓形 人們
human|person.crop.circle.fill.badge.checkmark|人 人物 圓形 勾 勾選 人們
human|person.crop.circle.fill.badge.minus|人 人物 圓形 減號 人們
human|person.crop.circle.fill.badge.plus|人 人物 圓形 加號 新增 人們
human|person.crop.circle.fill.badge.xmark|人 人物 圓形 叉 關閉 人們
human|person.crop.rectangle|人 人物 長方形 人們
human|person.crop.rectangle.badge.plus|人 人物 長方形 加號 新增 人們
human|person.crop.rectangle.badge.plus.fill|人 人物 長方形 加號 新增 人們
human|person.crop.rectangle.fill|人 人物 長方形 人們
human|person.crop.rectangle.stack|人 人物 長方形
human|person.crop.rectangle.stack.fill|人 人物 長方形
human|person.crop.square|人 人物 方形 人們
human|person.crop.square.badge.camera|人 人物 方形 相機 拍照 人們
human|person.crop.square.badge.camera.fill|人 人物 方形 相機 拍照 人們
human|person.crop.square.badge.video|人 人物 方形 影片 錄影 人們
human|person.crop.square.badge.video.fill|人 人物 方形 影片 錄影 人們
human|person.crop.square.fill|人 人物 方形 人們
human|person.crop.square.filled.and.at.rectangle|人 人物 方形 長方形 人們
human|person.crop.square.filled.and.at.rectangle.fill|人 人物 方形 長方形 人們
human|person.crop.square.on.square.angled|人 人物 方形 人們
human|person.crop.square.on.square.angled.fill|人 人物 方形 人們
human|person.fill|人 人物 人們
human|person.fill.and.arrow.left.and.arrow.right.outward|人 人物 箭頭 左 右 人們
human|person.fill.badge.minus|人 人物 減號 人們
human|person.fill.badge.plus|人 人物 加號 新增 人們
human|person.fill.checkmark|人 人物 勾 勾選 人們
human|person.fill.checkmark.and.xmark|人 人物 勾 勾選 叉 關閉 人們
human|person.fill.questionmark|人 人物 問號 人們
human|person.fill.turn.down|人 人物 下 人們
human|person.fill.turn.left|人 人物 左 人們
human|person.fill.turn.right|人 人物 右 人們
human|person.fill.viewfinder|人 人物 人們
human|person.fill.xmark|人 人物 叉 關閉 人們
human|person.line.dotted.person|人 人物 人們
human|person.line.dotted.person.fill|人 人物 人們
human|person.number.sign.rectangle|人 人物 長方形 人們
human|person.number.sign.rectangle.fill|人 人物 長方形 人們
human|person.slash|人 人物 正斜線 人們
human|person.slash.fill|人 人物 正斜線 人們
human|person.text.rectangle|人 人物 長方形 人們
human|person.text.rectangle.badge.clock|人 人物 長方形 時鐘 時間 人們
human|person.text.rectangle.badge.clock.fill|人 人物 長方形 時鐘 時間 人們
human|person.text.rectangle.fill|人 人物 長方形 人們
human|person.text.rectangle.trianglebadge.exclamationmark|人 人物 長方形 驚嘆號 警告 人們
human|person.text.rectangle.trianglebadge.exclamationmark.fill|人 人物 長方形 驚嘆號 警告 人們
human|person.wave.2|人 人物 人們
human|person.wave.2.fill|人 人物 人們
human|person.wave.2.inward|人 人物 人們
human|person.wave.2.inward.fill|人 人物 人們
human|rectangle.and.hand.point.up.left|長方形 手 上 左
human|rectangle.and.hand.point.up.left.fill|長方形 手 上 左
human|rectangle.and.hand.point.up.left.filled|長方形 手 上 左
human|rectangle.badge.person.crop|長方形 人 人物 人們
human|rectangle.fill.badge.person.crop|長方形 人 人物 人們
human|rectangle.filled.and.hand.point.up.left|長方形 手 上 左
human|rectangle.stack.and.person|長方形 人 人物
human|rectangle.stack.and.person.fill|長方形 人 人物
human|rectangle.stack.badge.person.crop|長方形 人 人物
human|rectangle.stack.badge.person.crop.fill|長方形 人 人物
human|shoeprints.fill|
human|square.on.square.badge.person.crop|方形 人 人物 人們
human|square.on.square.badge.person.crop.fill|方形 人 人物 人們
commerce|australiandollarsign|
commerce|australiandollarsign.building.classical|
commerce|australiandollarsign.building.classical.fill|
commerce|australiandollarsign.circle|圓形
commerce|australiandollarsign.circle.fill|圓形
commerce|australiandollarsign.gauge.chart.lefthalf.righthalf|圖表
commerce|australiandollarsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|australiandollarsign.ring|戒指
commerce|australiandollarsign.ring.dashed|戒指
commerce|australiandollarsign.square|方形
commerce|australiandollarsign.square.fill|方形
commerce|australsign|
commerce|australsign.building.classical|
commerce|australsign.building.classical.fill|
commerce|australsign.circle|圓形
commerce|australsign.circle.fill|圓形
commerce|australsign.gauge.chart.lefthalf.righthalf|圖表
commerce|australsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|australsign.ring|戒指
commerce|australsign.ring.dashed|戒指
commerce|australsign.square|方形
commerce|australsign.square.fill|方形
commerce|bag|包包 袋
commerce|bag.badge.minus|包包 袋 減號
commerce|bag.badge.plus|包包 袋 加號 新增
commerce|bag.badge.questionmark|包包 袋 問號
commerce|bag.circle|包包 袋 圓形
commerce|bag.circle.fill|包包 袋 圓形
commerce|bag.fill|包包 袋
commerce|bag.fill.badge.minus|包包 袋 減號
commerce|bag.fill.badge.plus|包包 袋 加號 新增
commerce|bag.fill.badge.questionmark|包包 袋 問號
commerce|bahtsign|
commerce|bahtsign.building.classical|
commerce|bahtsign.building.classical.fill|
commerce|bahtsign.circle|圓形
commerce|bahtsign.circle.fill|圓形
commerce|bahtsign.gauge.chart.lefthalf.righthalf|圖表
commerce|bahtsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|bahtsign.ring|戒指
commerce|bahtsign.ring.dashed|戒指
commerce|bahtsign.square|方形
commerce|bahtsign.square.fill|方形
commerce|banknote|鈔票 錢
commerce|banknote.fill|鈔票 錢
commerce|basket|籃子
commerce|basket.fill|籃子
commerce|bitcoinsign|
commerce|bitcoinsign.building.classical|
commerce|bitcoinsign.building.classical.fill|
commerce|bitcoinsign.circle|圓形
commerce|bitcoinsign.circle.fill|圓形
commerce|bitcoinsign.gauge.chart.lefthalf.righthalf|圖表
commerce|bitcoinsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|bitcoinsign.ring|戒指
commerce|bitcoinsign.ring.dashed|戒指
commerce|bitcoinsign.square|方形
commerce|bitcoinsign.square.fill|方形
commerce|brazilianrealsign|
commerce|brazilianrealsign.building.classical|
commerce|brazilianrealsign.building.classical.fill|
commerce|brazilianrealsign.circle|圓形
commerce|brazilianrealsign.circle.fill|圓形
commerce|brazilianrealsign.gauge.chart.lefthalf.righthalf|圖表
commerce|brazilianrealsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|brazilianrealsign.ring|戒指
commerce|brazilianrealsign.ring.dashed|戒指
commerce|brazilianrealsign.square|方形
commerce|brazilianrealsign.square.fill|方形
commerce|cart|購物車
commerce|cart.badge.clock|購物車 時鐘 時間
commerce|cart.badge.clock.fill|購物車 時鐘 時間
commerce|cart.badge.minus|購物車 減號
commerce|cart.badge.plus|購物車 加號 新增
commerce|cart.badge.questionmark|購物車 問號
commerce|cart.circle|購物車 圓形
commerce|cart.circle.fill|購物車 圓形
commerce|cart.fill|購物車
commerce|cart.fill.badge.minus|購物車 減號
commerce|cart.fill.badge.plus|購物車 加號 新增
commerce|cart.fill.badge.questionmark|購物車 問號
commerce|cedisign|
commerce|cedisign.building.classical|
commerce|cedisign.building.classical.fill|
commerce|cedisign.circle|圓形
commerce|cedisign.circle.fill|圓形
commerce|cedisign.gauge.chart.lefthalf.righthalf|圖表
commerce|cedisign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|cedisign.ring|戒指
commerce|cedisign.ring.dashed|戒指
commerce|cedisign.square|方形
commerce|cedisign.square.fill|方形
commerce|centsign|
commerce|centsign.building.classical|
commerce|centsign.building.classical.fill|
commerce|centsign.circle|圓形
commerce|centsign.circle.fill|圓形
commerce|centsign.gauge.chart.lefthalf.righthalf|圖表
commerce|centsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|centsign.ring|戒指
commerce|centsign.ring.dashed|戒指
commerce|centsign.square|方形
commerce|centsign.square.fill|方形
commerce|chineseyuanrenminbisign|
commerce|chineseyuanrenminbisign.building.classical|
commerce|chineseyuanrenminbisign.building.classical.fill|
commerce|chineseyuanrenminbisign.circle|圓形
commerce|chineseyuanrenminbisign.circle.fill|圓形
commerce|chineseyuanrenminbisign.gauge.chart.lefthalf.righthalf|圖表
commerce|chineseyuanrenminbisign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|chineseyuanrenminbisign.ring|戒指
commerce|chineseyuanrenminbisign.ring.dashed|戒指
commerce|chineseyuanrenminbisign.square|方形
commerce|chineseyuanrenminbisign.square.fill|方形
commerce|coloncurrencysign|貨幣
commerce|coloncurrencysign.building.classical|貨幣
commerce|coloncurrencysign.building.classical.fill|貨幣
commerce|coloncurrencysign.circle|貨幣 圓形
commerce|coloncurrencysign.circle.fill|貨幣 圓形
commerce|coloncurrencysign.gauge.chart.lefthalf.righthalf|貨幣 圖表
commerce|coloncurrencysign.gauge.chart.leftthird.topthird.rightthird|貨幣 圖表
commerce|coloncurrencysign.ring|貨幣 戒指
commerce|coloncurrencysign.ring.dashed|貨幣 戒指
commerce|coloncurrencysign.square|貨幣 方形
commerce|coloncurrencysign.square.fill|貨幣 方形
commerce|creditcard|信用卡
commerce|creditcard.and.numbers|信用卡
commerce|creditcard.arrow.trianglehead.2.clockwise.rotate.90|信用卡 箭頭
commerce|creditcard.badge.plus|信用卡 加號 新增
commerce|creditcard.badge.plus.fill|信用卡 加號 新增
commerce|creditcard.circle|信用卡 圓形
commerce|creditcard.circle.fill|信用卡 圓形
commerce|creditcard.fill|信用卡
commerce|creditcard.rewards|信用卡
commerce|creditcard.rewards.fill|信用卡
commerce|creditcard.trianglebadge.exclamationmark|信用卡 驚嘆號 警告
commerce|creditcard.trianglebadge.exclamationmark.fill|信用卡 驚嘆號 警告
commerce|cruzeirosign|
commerce|cruzeirosign.building.classical|
commerce|cruzeirosign.building.classical.fill|
commerce|cruzeirosign.circle|圓形
commerce|cruzeirosign.circle.fill|圓形
commerce|cruzeirosign.gauge.chart.lefthalf.righthalf|圖表
commerce|cruzeirosign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|cruzeirosign.ring|戒指
commerce|cruzeirosign.ring.dashed|戒指
commerce|cruzeirosign.square|方形
commerce|cruzeirosign.square.fill|方形
commerce|danishkronesign|
commerce|danishkronesign.building.classical|
commerce|danishkronesign.building.classical.fill|
commerce|danishkronesign.circle|圓形
commerce|danishkronesign.circle.fill|圓形
commerce|danishkronesign.gauge.chart.lefthalf.righthalf|圖表
commerce|danishkronesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|danishkronesign.ring|戒指
commerce|danishkronesign.ring.dashed|戒指
commerce|danishkronesign.square|方形
commerce|danishkronesign.square.fill|方形
commerce|dollarsign|美元
commerce|dollarsign.building.classical|美元
commerce|dollarsign.building.classical.fill|美元
commerce|dollarsign.circle|美元 圓形
commerce|dollarsign.circle.fill|美元 圓形
commerce|dollarsign.gauge.chart.lefthalf.righthalf|美元 圖表
commerce|dollarsign.gauge.chart.leftthird.topthird.rightthird|美元 圖表
commerce|dollarsign.ring|美元 戒指
commerce|dollarsign.ring.dashed|美元 戒指
commerce|dollarsign.square|美元 方形
commerce|dollarsign.square.fill|美元 方形
commerce|dongsign|
commerce|dongsign.building.classical|
commerce|dongsign.building.classical.fill|
commerce|dongsign.circle|圓形
commerce|dongsign.circle.fill|圓形
commerce|dongsign.gauge.chart.lefthalf.righthalf|圖表
commerce|dongsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|dongsign.ring|戒指
commerce|dongsign.ring.dashed|戒指
commerce|dongsign.square|方形
commerce|dongsign.square.fill|方形
commerce|eurosign|歐元
commerce|eurosign.building.classical|歐元
commerce|eurosign.building.classical.fill|歐元
commerce|eurosign.circle|歐元 圓形
commerce|eurosign.circle.fill|歐元 圓形
commerce|eurosign.gauge.chart.lefthalf.righthalf|歐元 圖表
commerce|eurosign.gauge.chart.leftthird.topthird.rightthird|歐元 圖表
commerce|eurosign.ring|歐元 戒指
commerce|eurosign.ring.dashed|歐元 戒指
commerce|eurosign.square|歐元 方形
commerce|eurosign.square.fill|歐元 方形
commerce|eurozonesign|
commerce|eurozonesign.building.classical|
commerce|eurozonesign.building.classical.fill|
commerce|eurozonesign.circle|圓形
commerce|eurozonesign.circle.fill|圓形
commerce|eurozonesign.gauge.chart.lefthalf.righthalf|圖表
commerce|eurozonesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|eurozonesign.ring|戒指
commerce|eurozonesign.ring.dashed|戒指
commerce|eurozonesign.square|方形
commerce|eurozonesign.square.fill|方形
commerce|florinsign|
commerce|florinsign.building.classical|
commerce|florinsign.building.classical.fill|
commerce|florinsign.circle|圓形
commerce|florinsign.circle.fill|圓形
commerce|florinsign.gauge.chart.lefthalf.righthalf|圖表
commerce|florinsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|florinsign.ring|戒指
commerce|florinsign.ring.dashed|戒指
commerce|florinsign.square|方形
commerce|florinsign.square.fill|方形
commerce|francsign|
commerce|francsign.building.classical|
commerce|francsign.building.classical.fill|
commerce|francsign.circle|圓形
commerce|francsign.circle.fill|圓形
commerce|francsign.gauge.chart.lefthalf.righthalf|圖表
commerce|francsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|francsign.ring|戒指
commerce|francsign.ring.dashed|戒指
commerce|francsign.square|方形
commerce|francsign.square.fill|方形
commerce|gauge.chart.lefthalf.righthalf|圖表
commerce|gauge.chart.leftthird.topthird.rightthird|圖表
commerce|giftcard|禮物卡
commerce|giftcard.fill|禮物卡
commerce|guaranisign|
commerce|guaranisign.building.classical|
commerce|guaranisign.building.classical.fill|
commerce|guaranisign.circle|圓形
commerce|guaranisign.circle.fill|圓形
commerce|guaranisign.gauge.chart.lefthalf.righthalf|圖表
commerce|guaranisign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|guaranisign.ring|戒指
commerce|guaranisign.ring.dashed|戒指
commerce|guaranisign.square|方形
commerce|guaranisign.square.fill|方形
commerce|hryvniasign|
commerce|hryvniasign.building.classical|
commerce|hryvniasign.building.classical.fill|
commerce|hryvniasign.circle|圓形
commerce|hryvniasign.circle.fill|圓形
commerce|hryvniasign.gauge.chart.lefthalf.righthalf|圖表
commerce|hryvniasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|hryvniasign.ring|戒指
commerce|hryvniasign.ring.dashed|戒指
commerce|hryvniasign.square|方形
commerce|hryvniasign.square.fill|方形
commerce|indianrupeesign|
commerce|indianrupeesign.building.classical|
commerce|indianrupeesign.building.classical.fill|
commerce|indianrupeesign.circle|圓形
commerce|indianrupeesign.circle.fill|圓形
commerce|indianrupeesign.gauge.chart.lefthalf.righthalf|圖表
commerce|indianrupeesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|indianrupeesign.ring|戒指
commerce|indianrupeesign.ring.dashed|戒指
commerce|indianrupeesign.square|方形
commerce|indianrupeesign.square.fill|方形
commerce|kipsign|
commerce|kipsign.building.classical|
commerce|kipsign.building.classical.fill|
commerce|kipsign.circle|圓形
commerce|kipsign.circle.fill|圓形
commerce|kipsign.gauge.chart.lefthalf.righthalf|圖表
commerce|kipsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|kipsign.ring|戒指
commerce|kipsign.ring.dashed|戒指
commerce|kipsign.square|方形
commerce|kipsign.square.fill|方形
commerce|larisign|
commerce|larisign.building.classical|
commerce|larisign.building.classical.fill|
commerce|larisign.circle|圓形
commerce|larisign.circle.fill|圓形
commerce|larisign.gauge.chart.lefthalf.righthalf|圖表
commerce|larisign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|larisign.ring|戒指
commerce|larisign.ring.dashed|戒指
commerce|larisign.square|方形
commerce|larisign.square.fill|方形
commerce|lirasign|
commerce|lirasign.building.classical|
commerce|lirasign.building.classical.fill|
commerce|lirasign.circle|圓形
commerce|lirasign.circle.fill|圓形
commerce|lirasign.gauge.chart.lefthalf.righthalf|圖表
commerce|lirasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|lirasign.ring|戒指
commerce|lirasign.ring.dashed|戒指
commerce|lirasign.square|方形
commerce|lirasign.square.fill|方形
commerce|malaysianringgitsign|
commerce|malaysianringgitsign.building.classical|
commerce|malaysianringgitsign.building.classical.fill|
commerce|malaysianringgitsign.circle|圓形
commerce|malaysianringgitsign.circle.fill|圓形
commerce|malaysianringgitsign.gauge.chart.lefthalf.righthalf|圖表
commerce|malaysianringgitsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|malaysianringgitsign.ring|戒指
commerce|malaysianringgitsign.ring.dashed|戒指
commerce|malaysianringgitsign.square|方形
commerce|malaysianringgitsign.square.fill|方形
commerce|manatsign|
commerce|manatsign.building.classical|
commerce|manatsign.building.classical.fill|
commerce|manatsign.circle|圓形
commerce|manatsign.circle.fill|圓形
commerce|manatsign.gauge.chart.lefthalf.righthalf|圖表
commerce|manatsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|manatsign.ring|戒指
commerce|manatsign.ring.dashed|戒指
commerce|manatsign.square|方形
commerce|manatsign.square.fill|方形
commerce|millsign|
commerce|millsign.building.classical|
commerce|millsign.building.classical.fill|
commerce|millsign.circle|圓形
commerce|millsign.circle.fill|圓形
commerce|millsign.gauge.chart.lefthalf.righthalf|圖表
commerce|millsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|millsign.ring|戒指
commerce|millsign.ring.dashed|戒指
commerce|millsign.square|方形
commerce|millsign.square.fill|方形
commerce|nairasign|
commerce|nairasign.building.classical|
commerce|nairasign.building.classical.fill|
commerce|nairasign.circle|圓形
commerce|nairasign.circle.fill|圓形
commerce|nairasign.gauge.chart.lefthalf.righthalf|圖表
commerce|nairasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|nairasign.ring|戒指
commerce|nairasign.ring.dashed|戒指
commerce|nairasign.square|方形
commerce|nairasign.square.fill|方形
commerce|norwegiankronesign|
commerce|norwegiankronesign.building.classical|
commerce|norwegiankronesign.building.classical.fill|
commerce|norwegiankronesign.circle|圓形
commerce|norwegiankronesign.circle.fill|圓形
commerce|norwegiankronesign.gauge.chart.lefthalf.righthalf|圖表
commerce|norwegiankronesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|norwegiankronesign.ring|戒指
commerce|norwegiankronesign.ring.dashed|戒指
commerce|norwegiankronesign.square|方形
commerce|norwegiankronesign.square.fill|方形
commerce|peruviansolessign|
commerce|peruviansolessign.building.classical|
commerce|peruviansolessign.building.classical.fill|
commerce|peruviansolessign.circle|圓形
commerce|peruviansolessign.circle.fill|圓形
commerce|peruviansolessign.gauge.chart.lefthalf.righthalf|圖表
commerce|peruviansolessign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|peruviansolessign.ring|戒指
commerce|peruviansolessign.ring.dashed|戒指
commerce|peruviansolessign.square|方形
commerce|peruviansolessign.square.fill|方形
commerce|pesetasign|
commerce|pesetasign.building.classical|
commerce|pesetasign.building.classical.fill|
commerce|pesetasign.circle|圓形
commerce|pesetasign.circle.fill|圓形
commerce|pesetasign.gauge.chart.lefthalf.righthalf|圖表
commerce|pesetasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|pesetasign.ring|戒指
commerce|pesetasign.ring.dashed|戒指
commerce|pesetasign.square|方形
commerce|pesetasign.square.fill|方形
commerce|pesosign|
commerce|pesosign.building.classical|
commerce|pesosign.building.classical.fill|
commerce|pesosign.circle|圓形
commerce|pesosign.circle.fill|圓形
commerce|pesosign.gauge.chart.lefthalf.righthalf|圖表
commerce|pesosign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|pesosign.ring|戒指
commerce|pesosign.ring.dashed|戒指
commerce|pesosign.square|方形
commerce|pesosign.square.fill|方形
commerce|polishzlotysign|
commerce|polishzlotysign.building.classical|
commerce|polishzlotysign.building.classical.fill|
commerce|polishzlotysign.circle|圓形
commerce|polishzlotysign.circle.fill|圓形
commerce|polishzlotysign.gauge.chart.lefthalf.righthalf|圖表
commerce|polishzlotysign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|polishzlotysign.ring|戒指
commerce|polishzlotysign.ring.dashed|戒指
commerce|polishzlotysign.square|方形
commerce|polishzlotysign.square.fill|方形
commerce|ring|戒指
commerce|ring.dashed|戒指
commerce|rublesign|
commerce|rublesign.building.classical|
commerce|rublesign.building.classical.fill|
commerce|rublesign.circle|圓形
commerce|rublesign.circle.fill|圓形
commerce|rublesign.gauge.chart.lefthalf.righthalf|圖表
commerce|rublesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|rublesign.ring|戒指
commerce|rublesign.ring.dashed|戒指
commerce|rublesign.square|方形
commerce|rublesign.square.fill|方形
commerce|rupeesign|
commerce|rupeesign.building.classical|
commerce|rupeesign.building.classical.fill|
commerce|rupeesign.circle|圓形
commerce|rupeesign.circle.fill|圓形
commerce|rupeesign.gauge.chart.lefthalf.righthalf|圖表
commerce|rupeesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|rupeesign.ring|戒指
commerce|rupeesign.ring.dashed|戒指
commerce|rupeesign.square|方形
commerce|rupeesign.square.fill|方形
commerce|shekelsign|
commerce|shekelsign.building.classical|
commerce|shekelsign.building.classical.fill|
commerce|shekelsign.circle|圓形
commerce|shekelsign.circle.fill|圓形
commerce|shekelsign.gauge.chart.lefthalf.righthalf|圖表
commerce|shekelsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|shekelsign.ring|戒指
commerce|shekelsign.ring.dashed|戒指
commerce|shekelsign.square|方形
commerce|shekelsign.square.fill|方形
commerce|signature|簽名
commerce|singaporedollarsign|
commerce|singaporedollarsign.building.classical|
commerce|singaporedollarsign.building.classical.fill|
commerce|singaporedollarsign.circle|圓形
commerce|singaporedollarsign.circle.fill|圓形
commerce|singaporedollarsign.gauge.chart.lefthalf.righthalf|圖表
commerce|singaporedollarsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|singaporedollarsign.ring|戒指
commerce|singaporedollarsign.ring.dashed|戒指
commerce|singaporedollarsign.square|方形
commerce|singaporedollarsign.square.fill|方形
commerce|sterlingsign|
commerce|sterlingsign.building.classical|
commerce|sterlingsign.building.classical.fill|
commerce|sterlingsign.circle|圓形
commerce|sterlingsign.circle.fill|圓形
commerce|sterlingsign.gauge.chart.lefthalf.righthalf|圖表
commerce|sterlingsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|sterlingsign.ring|戒指
commerce|sterlingsign.ring.dashed|戒指
commerce|sterlingsign.square|方形
commerce|sterlingsign.square.fill|方形
commerce|swedishkronasign|
commerce|swedishkronasign.building.classical|
commerce|swedishkronasign.building.classical.fill|
commerce|swedishkronasign.circle|圓形
commerce|swedishkronasign.circle.fill|圓形
commerce|swedishkronasign.gauge.chart.lefthalf.righthalf|圖表
commerce|swedishkronasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|swedishkronasign.ring|戒指
commerce|swedishkronasign.ring.dashed|戒指
commerce|swedishkronasign.square|方形
commerce|swedishkronasign.square.fill|方形
commerce|tengesign|
commerce|tengesign.building.classical|
commerce|tengesign.building.classical.fill|
commerce|tengesign.circle|圓形
commerce|tengesign.circle.fill|圓形
commerce|tengesign.gauge.chart.lefthalf.righthalf|圖表
commerce|tengesign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|tengesign.ring|戒指
commerce|tengesign.ring.dashed|戒指
commerce|tengesign.square|方形
commerce|tengesign.square.fill|方形
commerce|tugriksign|
commerce|tugriksign.building.classical|
commerce|tugriksign.building.classical.fill|
commerce|tugriksign.circle|圓形
commerce|tugriksign.circle.fill|圓形
commerce|tugriksign.gauge.chart.lefthalf.righthalf|圖表
commerce|tugriksign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|tugriksign.ring|戒指
commerce|tugriksign.ring.dashed|戒指
commerce|tugriksign.square|方形
commerce|tugriksign.square.fill|方形
commerce|turkishlirasign|
commerce|turkishlirasign.building.classical|
commerce|turkishlirasign.building.classical.fill|
commerce|turkishlirasign.circle|圓形
commerce|turkishlirasign.circle.fill|圓形
commerce|turkishlirasign.gauge.chart.lefthalf.righthalf|圖表
commerce|turkishlirasign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|turkishlirasign.ring|戒指
commerce|turkishlirasign.ring.dashed|戒指
commerce|turkishlirasign.square|方形
commerce|turkishlirasign.square.fill|方形
commerce|wonsign|
commerce|wonsign.building.classical|
commerce|wonsign.building.classical.fill|
commerce|wonsign.circle|圓形
commerce|wonsign.circle.fill|圓形
commerce|wonsign.gauge.chart.lefthalf.righthalf|圖表
commerce|wonsign.gauge.chart.leftthird.topthird.rightthird|圖表
commerce|wonsign.ring|戒指
commerce|wonsign.ring.dashed|戒指
commerce|wonsign.square|方形
commerce|wonsign.square.fill|方形
commerce|yensign|日圓
commerce|yensign.building.classical|日圓
commerce|yensign.building.classical.fill|日圓
commerce|yensign.circle|日圓 圓形
commerce|yensign.circle.fill|日圓 圓形
commerce|yensign.gauge.chart.lefthalf.righthalf|日圓 圖表
commerce|yensign.gauge.chart.leftthird.topthird.rightthird|日圓 圖表
commerce|yensign.ring|日圓 戒指
commerce|yensign.ring.dashed|日圓 戒指
commerce|yensign.square|日圓 方形
commerce|yensign.square.fill|日圓 方形
communication|backward.bubble|倒轉
communication|backward.bubble.fill|倒轉
communication|bubble|
communication|bubble.and.pencil|鉛筆
communication|bubble.circle|圓形
communication|bubble.circle.fill|圓形
communication|bubble.fill|
communication|bubble.left|左
communication|bubble.left.and.bubble.right|左 右
communication|bubble.left.and.bubble.right.fill|左 右
communication|bubble.left.and.exclamationmark.bubble.right|左 驚嘆號 警告 右
communication|bubble.left.and.exclamationmark.bubble.right.fill|左 驚嘆號 警告 右
communication|bubble.left.and.heart.bubble.right|左 愛心 心 右
communication|bubble.left.and.heart.bubble.right.fill|左 愛心 心 右
communication|bubble.left.and.text.bubble.right|左 右
communication|bubble.left.and.text.bubble.right.fill|左 右
communication|bubble.left.circle|左 圓形
communication|bubble.left.circle.fill|左 圓形
communication|bubble.left.fill|左
communication|bubble.middle.bottom|
communication|bubble.middle.bottom.fill|
communication|bubble.middle.top|
communication|bubble.middle.top.fill|
communication|bubble.right|右
communication|bubble.right.circle|右 圓形
communication|bubble.right.circle.fill|右 圓形
communication|bubble.right.fill|右
communication|character.bubble|
communication|character.bubble.fill|
communication|character.bubble.fill.mni|
communication|character.bubble.mni|
communication|checkmark.bubble|勾 勾選
communication|checkmark.bubble.fill|勾 勾選
communication|ellipsis.vertical.bubble|省略號
communication|ellipsis.vertical.bubble.fill|省略號
communication|envelope|信封 郵件
communication|envelope.and.arrow.trianglehead.branch|信封 郵件 箭頭
communication|envelope.and.arrow.trianglehead.branch.fill|信封 郵件 箭頭
communication|envelope.and.hand.raised|信封 郵件 手
communication|envelope.and.hand.raised.fill|信封 郵件 手
communication|envelope.badge|信封 郵件
communication|envelope.badge.fill|信封 郵件
communication|envelope.badge.minus|信封 郵件 減號
communication|envelope.badge.minus.fill|信封 郵件 減號
communication|envelope.badge.person.crop|信封 郵件 人 人物
communication|envelope.badge.person.crop.fill|信封 郵件 人 人物
communication|envelope.badge.plus|信封 郵件 加號 新增
communication|envelope.badge.plus.fill|信封 郵件 加號 新增
communication|envelope.badge.shield.half.filled|信封 郵件 盾牌
communication|envelope.badge.shield.half.filled.fill|信封 郵件 盾牌
communication|envelope.circle|信封 郵件 圓形
communication|envelope.circle.fill|信封 郵件 圓形
communication|envelope.fill|信封 郵件
communication|envelope.front|信封 郵件
communication|envelope.front.fill|信封 郵件
communication|envelope.open|信封 郵件
communication|envelope.open.badge.clock|信封 郵件 時鐘 時間
communication|envelope.open.badge.clock.fill|信封 郵件 時鐘 時間
communication|envelope.open.fill|信封 郵件
communication|envelope.stack|信封 郵件
communication|envelope.stack.fill|信封 郵件
communication|exclamationmark.bubble|驚嘆號 警告
communication|exclamationmark.bubble.circle|驚嘆號 警告 圓形
communication|exclamationmark.bubble.circle.fill|驚嘆號 警告 圓形
communication|exclamationmark.bubble.fill|驚嘆號 警告
communication|field.of.view.ultrawide|
communication|field.of.view.ultrawide.fill|
communication|field.of.view.wide|
communication|field.of.view.wide.fill|
communication|info.bubble|資訊
communication|info.bubble.fill|資訊
communication|inset.filled.bubble|
communication|line.diagonal|
communication|line.diagonal.trianglehead.up.right|上 右
communication|line.diagonal.trianglehead.up.right.left.down|上 右 左 下
communication|microphone|麥克風
communication|microphone.and.signal.meter|麥克風
communication|microphone.and.signal.meter.fill|麥克風
communication|microphone.badge.ellipsis|麥克風 省略號
communication|microphone.badge.ellipsis.fill|麥克風 省略號
communication|microphone.badge.plus|麥克風 加號 新增
communication|microphone.badge.plus.fill|麥克風 加號 新增
communication|microphone.badge.xmark|麥克風 叉 關閉
communication|microphone.badge.xmark.fill|麥克風 叉 關閉
communication|microphone.circle|麥克風 圓形
communication|microphone.circle.fill|麥克風 圓形
communication|microphone.fill|麥克風
communication|microphone.slash|麥克風 正斜線
communication|microphone.slash.circle|麥克風 正斜線 圓形
communication|microphone.slash.circle.fill|麥克風 正斜線 圓形
communication|microphone.slash.fill|麥克風 正斜線
communication|microphone.square|麥克風 方形
communication|microphone.square.fill|麥克風 方形
communication|person.bubble|人 人物
communication|person.bubble.fill|人 人物
communication|phone|電話 手機
communication|phone.arrow.down.left|電話 手機 箭頭 下 左
communication|phone.arrow.down.left.fill|電話 手機 箭頭 下 左
communication|phone.arrow.right|電話 手機 箭頭 右
communication|phone.arrow.right.fill|電話 手機 箭頭 右
communication|phone.arrow.up.right|電話 手機 箭頭 上 右
communication|phone.arrow.up.right.circle|電話 手機 箭頭 上 右 圓形
communication|phone.arrow.up.right.circle.fill|電話 手機 箭頭 上 右 圓形
communication|phone.arrow.up.right.fill|電話 手機 箭頭 上 右
communication|phone.badge.checkmark|電話 手機 勾 勾選
communication|phone.badge.clock|電話 手機 時鐘 時間
communication|phone.badge.clock.fill|電話 手機 時鐘 時間
communication|phone.badge.plus|電話 手機 加號 新增
communication|phone.badge.waveform|電話 手機
communication|phone.badge.waveform.fill|電話 手機
communication|phone.bubble|電話 手機
communication|phone.bubble.fill|電話 手機
communication|phone.circle|電話 手機 圓形
communication|phone.circle.fill|電話 手機 圓形
communication|phone.connection|電話 手機
communication|phone.connection.fill|電話 手機
communication|phone.down|電話 手機 下
communication|phone.down.circle|電話 手機 下 圓形
communication|phone.down.circle.fill|電話 手機 下 圓形
communication|phone.down.fill|電話 手機 下
communication|phone.down.waves.left.and.right|電話 手機 下 波浪 左 右
communication|phone.fill|電話 手機
communication|phone.fill.badge.checkmark|電話 手機 勾 勾選
communication|phone.fill.badge.plus|電話 手機 加號 新增
communication|phone.pause|電話 手機 暫停
communication|phone.pause.circle|電話 手機 暫停 圓形
communication|phone.pause.circle.fill|電話 手機 暫停 圓形
communication|phone.pause.fill|電話 手機 暫停
communication|play.bubble|播放
communication|play.bubble.fill|播放
communication|plus.bubble|加號 新增
communication|plus.bubble.fill|加號 新增
communication|questionmark.bubble|問號
communication|questionmark.bubble.fill|問號
communication|quote.closing|
communication|quote.opening|
communication|recordingtape|
communication|recordingtape.badge|
communication|recordingtape.circle|圓形
communication|recordingtape.circle.fill|圓形
communication|speaker.wave.2.bubble|喇叭 音量
communication|speaker.wave.2.bubble.fill|喇叭 音量
communication|star.bubble|星星 星
communication|star.bubble.fill|星星 星
communication|stroke.line.diagonal|
communication|stroke.line.diagonal.slash|正斜線
communication|text.bubble|
communication|text.bubble.badge.clock|時鐘 時間
communication|text.bubble.badge.clock.fill|時鐘 時間
communication|text.bubble.badge.sparkles|閃亮 星光
communication|text.bubble.badge.sparkles.fill|閃亮 星光
communication|text.bubble.fill|
communication|waveform|備忘錄
communication|waveform.and.person|人 人物 人們
communication|waveform.badge.checkmark|勾 勾選
communication|waveform.badge.exclamationmark|驚嘆號 警告
communication|waveform.badge.microphone|麥克風
communication|waveform.badge.minus|減號
communication|waveform.badge.plus|加號 新增
communication|waveform.badge.xmark|叉 關閉
communication|waveform.circle|圓形 備忘錄
communication|waveform.circle.fill|圓形 備忘錄
communication|waveform.low|
communication|waveform.mid|
communication|waveform.slash|正斜線
privacyandsecurity|checkmark|勾 勾選
privacyandsecurity|checkmark.circle|勾 勾選 圓形
privacyandsecurity|checkmark.circle.badge.plus|勾 勾選 圓形 加號 新增
privacyandsecurity|checkmark.circle.badge.plus.fill|勾 勾選 圓形 加號 新增
privacyandsecurity|checkmark.circle.badge.questionmark|勾 勾選 圓形 問號
privacyandsecurity|checkmark.circle.badge.questionmark.fill|勾 勾選 圓形 問號
privacyandsecurity|checkmark.circle.badge.xmark|勾 勾選 圓形 叉 關閉
privacyandsecurity|checkmark.circle.badge.xmark.fill|勾 勾選 圓形 叉 關閉
privacyandsecurity|checkmark.circle.dotted|勾 勾選 圓形
privacyandsecurity|checkmark.circle.fill|勾 勾選 圓形
privacyandsecurity|checkmark.circle.trianglebadge.exclamationmark|勾 勾選 圓形 驚嘆號 警告
privacyandsecurity|checkmark.circle.trianglebadge.exclamationmark.fill|勾 勾選 圓形 驚嘆號 警告
privacyandsecurity|checkmark.diamond|勾 勾選
privacyandsecurity|checkmark.diamond.fill|勾 勾選
privacyandsecurity|checkmark.rectangle|勾 勾選 長方形
privacyandsecurity|checkmark.rectangle.fill|勾 勾選 長方形
privacyandsecurity|checkmark.rectangle.portrait|勾 勾選 長方形
privacyandsecurity|checkmark.rectangle.portrait.fill|勾 勾選 長方形
privacyandsecurity|checkmark.seal|勾 勾選 海豹
privacyandsecurity|checkmark.seal.fill|勾 勾選 海豹
privacyandsecurity|checkmark.square|勾 勾選 方形
privacyandsecurity|checkmark.square.fill|勾 勾選 方形
privacyandsecurity|firewall|箭頭
privacyandsecurity|firewall.fill|箭頭
privacyandsecurity|hand.raised.square.on.square|手 方形
privacyandsecurity|hand.raised.square.on.square.fill|手 方形
privacyandsecurity|key.shield|鑰匙 盾牌
privacyandsecurity|key.shield.fill|鑰匙 盾牌
privacyandsecurity|nosign|正斜線
privacyandsecurity|nosign.app|正斜線
privacyandsecurity|nosign.app.fill|正斜線
privacyandsecurity|nosign.badge.clock|時鐘 時間 正斜線
privacyandsecurity|seal|海豹
privacyandsecurity|seal.fill|海豹
privacyandsecurity|xmark.seal|叉 關閉 海豹 乘
privacyandsecurity|xmark.seal.fill|叉 關閉 海豹 乘
time|globe.badge.clock|地球 時鐘 時間
time|globe.badge.clock.fill|地球 時鐘 時間
"""
}
