// 由 Unicode emoji-test.txt（18.0）產生：只留完整合格的表情，膚色與髮色變體由選擇器另外展開。
// 每行：分類|表情|加入的 Emoji 版本|英文名稱。
enum EmojiData {
    static let raw = """
Smileys & Emotion|😀|1.0|grinning face|微笑 欣喜 笑容 笑臉 臉 露齒而笑
Smileys & Emotion|😃|0.6|grinning face with big eyes|呵呵 咧嘴大笑 哈哈 大笑 笑臉 臉
Smileys & Emotion|😄|0.6|grinning face with smiling eyes|呵呵 哈哈 笑臉 臉
Smileys & Emotion|😁|0.6|beaming face with smiling eyes|嘻嘻 笑臉 笑顏逐開 臉 露齒而笑
Smileys & Emotion|😆|0.6|grinning squinting face|呵呵 哈哈 好笑 狂笑 笑口大開 笑臉 臉
Smileys & Emotion|😅|0.6|grinning face with sweat|冒冷汗 汗 笑臉冒冷汗 緊張 臉 苦笑
Smileys & Emotion|🤣|3.0|rolling on the floor laughing|lol 哭笑不得 捧腹 笑 笑到眼淚出來 笑翻了 翻 臉
Smileys & Emotion|😂|0.6|face with tears of joy|呵呵 哈哈 哭笑不得 喜極而泣 大笑 好笑 感動 極度滑稽 滑稽 臉
Smileys & Emotion|🙂|1.0|slightly smiling face|呆呆笑 微笑 快樂 笑臉 臉
Smileys & Emotion|🙃|1.0|upside-down face|亂了套 臉 臉上下顛倒 顛倒臉
Smileys & Emotion|🫠|14.0|melting face|哈哈 大笑 尷尬 液態的臉 溶解的臉 炎熱 熱 融化 融化中 融化的臉 諷刺
Smileys & Emotion|🫫|18.0|cracking face|
Smileys & Emotion|😉|0.6|winking face|傷心 眨眼 臉 表情 調情
Smileys & Emotion|😊|0.6|smiling face with smiling eyes|微笑 眼睛也在笑 笑臉 臉
Smileys & Emotion|😇|1.0|smiling face with halo|光暈 天使笑臉 天真無邪 純真笑臉 臉
Smileys & Emotion|🥰|11.0|smiling face with hearts|一見鐘情 三個愛心的笑臉 三顆心的笑臉 喜歡 愛 愛慕 戀愛了 我愛你 笑 笑臉 臉 迷戀
Smileys & Emotion|😍|0.6|smiling face with heart-eyes|心花怒放 戀愛中 臉 花痴
Smileys & Emotion|🤩|5.0|star-struck|星星 滿眼星光 眼冒星星 眼睛 笑臉 臉 讚嘆 追星 露齒笑
Smileys & Emotion|😘|0.6|face blowing a kiss|女朋友 我愛你 擁抱親吻 男朋友 臉 親親 親親飛吻 飛吻
Smileys & Emotion|😗|1.0|kissing face|嘟嘴 我愛你 擁抱親吻 臉 表情 親嘴 親臉 親親
Smileys & Emotion|☺️|0.6|smiling face|快樂 放鬆一笑 臉 輕鬆笑臉
Smileys & Emotion|😚|0.6|kissing face with closed eyes|瞇眼親親 臉 親親 閉眼親吻
Smileys & Emotion|😙|1.0|kissing face with smiling eyes|笑臉親親 笑著親臉 臉 親親
Smileys & Emotion|🥲|13.0|smiling face with tear|微笑帶淚 感動 感恩 感激 流淚 淚 痛苦 表情符號 開心 驕傲 高興 鬆一口氣
Smileys & Emotion|😋|0.6|face savoring food|口水 回味 夠味 好吃 臉
Smileys & Emotion|😛|1.0|face with tongue|吐舌頭 嘿嘿 臉
Smileys & Emotion|😜|0.6|winking face with tongue|吐舌頭 嘿嘿 眨眼吐舌 臉 頑皮
Smileys & Emotion|🤪|5.0|zany face|大小眼 瘋狂的臉 瘋臉 發瘋
Smileys & Emotion|😝|0.6|squinting face with tongue|OMG 吐舌頭 嘿嘿 我的媽 眨眼吐舌頭 臉
Smileys & Emotion|🤑|1.0|money-mouth face|發財 臉 見錢眼開
Smileys & Emotion|🤗|1.0|smiling face with open hands|抱抱 擁抱 臉
Smileys & Emotion|🤭|5.0|face with hand over mouth|傻笑 咯咯 哎喲 手蓋住嘴巴 掩嘴笑 驚喜
Smileys & Emotion|🫢|14.0|face with open eyes and hand over mouth|不敢相信 倒抽氣 嚇到 天啊 尷尬 張眼摀嘴的臉 敬畏 說不出話 驚嚇 驚奇 驚訝
Smileys & Emotion|🫣|14.0|face with peeking eye|一眼偷看的臉 偷看 偷瞄 凝視 害怕 害羞 注視 窺視 著迷 躲藏 躲起來 難為情
Smileys & Emotion|🤫|5.0|shushing face|噓 安靜
Smileys & Emotion|🤔|1.0|thinking face|思考 沈思 臉 表情
Smileys & Emotion|🫡|14.0|saluting face|尊重 敬禮 敬禮的臉 是 是的 祝好運 遵命 部隊 陽光
Smileys & Emotion|🤐|1.0|zipper-mouth face|不能講 住嘴 嘴上拉鍊 臉 閉嘴
Smileys & Emotion|🤨|5.0|face with raised eyebrow|不相信 不贊同 意外 懷疑 挑眉驚訝 提眉 揚眉 臉
Smileys & Emotion|😐|0.7|neutral face|無反應 無語 臉 表情 面無表情
Smileys & Emotion|😑|1.0|expressionless face|撲克臉 無語 臉 面無表情
Smileys & Emotion|😶|1.0|face without mouth|安靜 沉默 無嘴的臉 無語 臉 表情 面無表親
Smileys & Emotion|🫥|14.0|dotted line face|內向 失望 沮喪 無所謂 虛線的臉 躲起來 透明人 隨便 隱形
Smileys & Emotion|😶‍🌫️|13.1|face in clouds|一頭霧水 茫茫然
Smileys & Emotion|😏|0.6|smirking face|假笑 冷笑 臉
Smileys & Emotion|😒|0.6|unamused face|不開心 不高興 嫉妒 臉
Smileys & Emotion|🙄|1.0|face with rolling eyes|不屑 翻白眼 臉 鄙視 隨便
Smileys & Emotion|😬|1.0|grimacing face|咬牙 咬牙切齒 臉 露齒而笑 鬼臉
Smileys & Emotion|😮‍💨|13.1|face exhaling|倒抽一口氣 吹 吹氣 呻吟 嘆氣 累 表情符號 鬆一口氣
Smileys & Emotion|🤥|3.0|lying face|小木偶 臉 說謊 變 長 鼻 鼻子變長了
Smileys & Emotion|🫨|15.0|shaking face|動搖 動搖的表情 地震 抖動 搖動 表情 震動 驚嚇，天啊，驚慌，暈頭轉向，震動，地震，搖晃，哇，瘋狂，驚喜，驚訝
Smileys & Emotion|🙂‍↔️|15.1|head shaking horizontally|不，搖頭 左右搖頭
Smileys & Emotion|🙂‍↕️|15.1|head shaking vertically|上下點頭 點頭，是
Smileys & Emotion|😌|0.6|relieved face|放下心 放鬆 臉 解脫 鬆了口氣
Smileys & Emotion|😔|0.6|pensive face|思考 沉思 深思 臉
Smileys & Emotion|😪|0.6|sleepy face|打瞌睡 掉淚 睏 臉 面臉倦容
Smileys & Emotion|🤤|3.0|drooling face|口 垂涎 水 流 流口水 臉
Smileys & Emotion|😴|1.0|sleeping face|夜裏 小歇 想睡 打呼 打瞌睡 晚安 睡臉 睡著了 累了 臉
Smileys & Emotion|🫩|16.0|face with bags under eyes|疲勞的 睏了 筋疲力盡 臉上有眼袋
Smileys & Emotion|😷|0.6|face with medical mask|口罩 戴口罩的臉 牙醫 生病 病菌 皮膚科 臉 醫生
Smileys & Emotion|🤒|1.0|face with thermometer|含溫度計 溫度計 生病 臉
Smileys & Emotion|🤕|1.0|face with head-bandage|包繃帶 受傷 臉 頭綁繃帶的臉
Smileys & Emotion|🤢|3.0|nauseated face|吐 噁心 想 想吐 臉
Smileys & Emotion|🤮|5.0|face vomiting|吐 吐臉 嘔吐 噁心 狂吐中 病懨懨 難受
Smileys & Emotion|🤧|3.0|sneezing face|保重 噴 嚏 感冒 打 打噴嚏 臉
Smileys & Emotion|🥵|11.0|hot face|中暑 冒汗 吐舌 好熱 死去 流汗 熱 熱臉 發熱 發燒 臉 臉紅
Smileys & Emotion|🥶|11.0|cold face|冰凍 冷 冷臉 冷面 凍傷 凍瘡 很冷 結霜 臉 臉色發青 藍色 藍色的臉
Smileys & Emotion|🥴|11.0|woozy face|喝多了 喝醉 嘴巴波浪 大小眼 微醺 波浪嘴 雙眼不平 頭昏 頭昏眼花 頭暈
Smileys & Emotion|😵|0.6|face with crossed-out eyes|困惑 臉 表情 頭昏 頭暈目眩
Smileys & Emotion|😵‍💫|13.1|face with spiral eyes|不懂 催眠 呃 哇 困惑 天啊 暈 暈眩 煩惱 目眩頭暈 眩暈 頭暈
Smileys & Emotion|🤯|5.0|exploding head|一個頭兩個大 爆炸頭 驚嚇
Smileys & Emotion|🤠|3.0|cowboy hat face|仔 牛 牛仔 臉
Smileys & Emotion|🥳|11.0|partying face|喝采 帽子 慶祝 慶祝的表情 歡呼 派對 生日 紙喇叭 臉 興奮
Smileys & Emotion|🥸|13.0|disguised face|人 假扮 假扮的臉 假鼻子 偽裝 眉毛 眼鏡 間諜 鬍子
Smileys & Emotion|😎|1.0|smiling face with sunglasses|太陽眼鏡 戴著墨鏡的笑臉 眼鏡 臉 自吹自擂 酷 墨鏡
Smileys & Emotion|🤓|1.0|nerd face|宅 怪人 搞怪 當阿宅 聰明，頭腦好，有智慧，專家，有天份，阿宅，傻，眼鏡，宅男，宅女，臉 臉
Smileys & Emotion|🧐|5.0|face with monocle|古板臉 單片眼鏡 奢華 有錢人 病厭厭 老古板
Smileys & Emotion|😕|1.0|confused face|不確定 困惑面容 困擾 臉 面有難色
Smileys & Emotion|🫤|14.0|face with diagonal mouth|不確定 受挫 困惑 失望 懷疑 挫折 歪嘴的臉 無所謂 疑惑 隨便
Smileys & Emotion|😟|1.0|worried face|憂心忡忡 擔心 臉
Smileys & Emotion|🙁|1.0|slightly frowning face|不開心 壞心情 微慍 皺眉 臉
Smileys & Emotion|☹️|0.7|frowning face|不滿意 不爽 悲哀 皺眉 臉
Smileys & Emotion|😮|1.0|face with open mouth|不可能 啊 我不信 臉 驚訝
Smileys & Emotion|😯|1.0|hushed face|哦 意外 臉 說不出話來 驚訝
Smileys & Emotion|😲|0.6|astonished face|怎麼可能 我的天 臉 震驚 驚
Smileys & Emotion|😳|0.6|flushed face|不可置信 太扯了 害羞 怎麼可能 愛慕 臉 臉紅 茫然
Smileys & Emotion|🫪|17.0|distorted face|恐慌 慌張 焦慮 脆弱 腫脹 驚喜 驚嚇 變形的臉
Smileys & Emotion|🥺|11.0|pleading face|大眼睛 懇求 拜託 求求你 無辜臉 請求的臉 請求臉孔
Smileys & Emotion|🥹|14.0|face holding back tears|仰慕 傷心 哭泣 喜極而泣 強忍淚水的臉 悲傷 感受 感激 感謝 抗拒 拜託 生氣 窩心 難為情 難過 驕傲
Smileys & Emotion|😦|1.0|frowning face with open mouth|啊 始料未及 張嘴皺眉 目瞪口呆 臉
Smileys & Emotion|😧|1.0|anguished face|痛 痛苦 臉 難受
Smileys & Emotion|😨|0.6|fearful face|可怕 害怕 幾乎落淚的臉 憂心 責備
Smileys & Emotion|😰|0.6|anxious face with sweat|冒汗 發冷 緊張 臉色發青 面有菜色
Smileys & Emotion|😥|0.6|sad but relieved face|倖免於難 失望卻解脫 好險 沮喪 流汗 臉 鬆了口氣
Smileys & Emotion|😢|0.6|crying face|哭臉 想念 流淚 淚 糟透了 臉
Smileys & Emotion|😭|0.6|loudly crying face|哭 哭臉 大哭 淚 淚流滿面 臉
Smileys & Emotion|😱|0.6|face screaming in fear|嚇死了 尖叫 恐怖 驚叫
Smileys & Emotion|😖|0.6|confounded face|侷促不安 困惑 滿臉困惑 焦頭爛額 臉
Smileys & Emotion|😣|0.6|persevering face|堅忍 專心 忍痛中 忍耐 痛苦 臉 頭痛
Smileys & Emotion|😞|0.6|disappointed face|失望 很糟 沮喪 臉 輸了
Smileys & Emotion|😓|0.6|downcast face with sweat|冒冷汗的臉 冷汗 臉 表情
Smileys & Emotion|😩|0.6|weary face|唉! 疲勞 疲憊 累 臉
Smileys & Emotion|😫|0.6|tired face|嘆氣 滿臉倦容 疲勞 疲憊 累 臉
Smileys & Emotion|🥱|12.0|yawning face|呵欠 小睡 想睡 想睡的臉 晚上 無聊 疲勞 瞌睡連連 都好
Smileys & Emotion|😤|0.6|face with steam from nose|傲慢 怒氣沖沖 揚眉吐氣 氣瘋了 生氣 發怒 臉
Smileys & Emotion|😡|0.6|enraged face|怒 漲紅了臉 生氣 發火 發飆 臉
Smileys & Emotion|😠|0.6|angry face|不爽 火大 生氣 臉 責怪
Smileys & Emotion|🤬|5.0|face with symbols on mouth|不爽 嘴上有符號的表情 發怒 發誓 詛咒
Smileys & Emotion|😈|1.0|smiling face with horns|惡魔的笑 邪惡的笑 陰暗地笑
Smileys & Emotion|👿|0.6|angry face with horns|怒氣惡臉 惡魔 臉 表情 邪惡
Smileys & Emotion|💀|0.6|skull|怪物 頭骨 骷髏 骷髏頭
Smileys & Emotion|☠️|1.0|skull and crossbones|交叉骷髏頭 死亡 海盜 頭殼 骷髏頭
Smileys & Emotion|💩|0.6|pile of poo|便便 大便 臭臭
Smileys & Emotion|🤡|3.0|clown face|丑 小 小丑 臉
Smileys & Emotion|👹|0.6|ogre|妖怪 惡鬼 表情 面具 食人巨妖 魔鬼
Smileys & Emotion|👺|0.6|goblin|天狗 妖怪 小妖怪 怪物 面具
Smileys & Emotion|👻|0.6|ghost|幽靈 萬聖節 鬧鬼 鬼 鬼臉
Smileys & Emotion|👽|0.6|alien|ET 外星人 幽浮
Smileys & Emotion|👾|0.6|alien monster|外星怪物 幽浮 怪物 電玩
Smileys & Emotion|🤖|1.0|robot|機器人
Smileys & Emotion|😺|0.6|grinning cat|呵呵 哈哈 笑口大開 笑口常開 笑臉
Smileys & Emotion|😸|0.6|grinning cat with smiling eyes|微笑的貓臉 笑臉
Smileys & Emotion|😹|0.6|cat with tears of joy|又哭又笑 喜極而泣 感動的貓臉 臉
Smileys & Emotion|😻|0.6|smiling cat with heart-eyes|心眼的貓臉 心花怒放 臉 花痴的貓臉
Smileys & Emotion|😼|0.6|cat with wry smile|冷嘲 動物 嘲笑的貓臉 嘲諷 微笑貓臉 笑 臉 貓
Smileys & Emotion|😽|0.6|kissing cat|動物 臉 親親 親親的貓臉 閉眼親親的貓臉
Smileys & Emotion|🙀|0.6|weary cat|意外 疲勞 疲憊 累 累的貓臉
Smileys & Emotion|😿|0.6|crying cat|動物 哭 哭的貓臉 哭臉 淚 臉
Smileys & Emotion|😾|0.6|pouting cat|噘嘴的貓臉 怒 生氣 生氣的貓臉 發火 發飆
Smileys & Emotion|🙈|0.6|see-no-evil monkey|不看 動物 我的天 遮眼 非禮勿視
Smileys & Emotion|🙉|0.6|hear-no-evil monkey|不聽 不許聽 秘密 遮耳 非禮勿聽
Smileys & Emotion|🙊|0.6|speak-no-evil monkey|動物 摀嘴 禁言 非禮勿言
Smileys & Emotion|💌|0.6|love letter|情人節 情書 愛的箴言
Smileys & Emotion|💘|0.6|heart with arrow|丘比特 愛 愛神的箭 戀愛
Smileys & Emotion|💝|0.6|heart with ribbon|情人節 愛的禮物 送你一顆心
Smileys & Emotion|💖|0.6|sparkling heart|吻 放閃 晚安 閃亮 開心
Smileys & Emotion|💗|0.6|growing heart|心動 心撲通跳 我愛你 緊張
Smileys & Emotion|💓|0.6|beating heart|心 心跳 愛 愛心跳動
Smileys & Emotion|💞|0.6|revolving hearts|心之舞 我愛你 舞動的心 週年紀念
Smileys & Emotion|💕|0.6|two hearts|心心相印 我愛你 相愛
Smileys & Emotion|💟|0.6|heart decoration|心在框框裏 心在框框裡 心型 我愛你 紫心
Smileys & Emotion|❣️|1.0|heart exclamation|心嘆號 心型驚嘆號
Smileys & Emotion|💔|0.6|broken heart|心碎 破碎的心
Smileys & Emotion|❤️‍🔥|13.1|heart on fire|奉獻 心型 愛 慾望 火熱的心
Smileys & Emotion|❤️‍🩹|13.1|mending heart|健康 恢復 療傷 療心
Smileys & Emotion|❤️|0.6|red heart|心型 愛心
Smileys & Emotion|🩷|15.0|pink heart|可愛 喜歡 心型 愛 粉紅 粉紅，愛，可愛，甜蜜，可愛的，特殊，心情，心，喜歡 粉紅心
Smileys & Emotion|🧡|5.0|orange heart|心型 橘心 橘色 橘色心
Smileys & Emotion|💛|0.6|yellow heart|心型 愛 我愛你 黃心
Smileys & Emotion|💚|0.6|green heart|心型 我愛你 綠心
Smileys & Emotion|💙|0.6|blue heart|心型 藍心
Smileys & Emotion|🩵|15.0|light blue heart|心型 淺藍 淺藍，天蘭，喜歡，心情，心，可愛，愛，特殊，藍綠 淺藍心 藍綠 青綠
Smileys & Emotion|💜|0.6|purple heart|心型 愛 我愛你 紫心
Smileys & Emotion|🤎|12.0|brown heart|咖啡色 心 愛心 褐 褐心 褐色
Smileys & Emotion|🖤|3.0|black heart|心 邪惡 黑 黑心
Smileys & Emotion|🩶|15.0|grey heart|心型 暗灰色 灰 灰色，特殊，心情，愛心，愛，銀色 灰色愛心 石板色 銀
Smileys & Emotion|🤍|12.0|white heart|心 愛心 白 白心 白色
Smileys & Emotion|💋|0.6|kiss mark|吻 唇印 性感 約會 親親
Smileys & Emotion|💯|0.6|hundred points|100分 滿分 絕對
Smileys & Emotion|💢|0.6|anger symbol|怒 火大 爆青筋
Smileys & Emotion|🫯|17.0|fight cloud|不同意 戰鬥 搏鬥 爭論 辯論 騷動 鬥毆 打鬥的雲
Smileys & Emotion|💥|0.6|collision|引爆 炸彈 爆炸 碰撞
Smileys & Emotion|💫|0.6|dizzy|星星 暈頭轉向 流星 頭暈目眩
Smileys & Emotion|💦|0.6|sweat droplets|出汗 水珠 汗 訓練
Smileys & Emotion|💨|0.6|dashing away|揚塵而去 放屁
Smileys & Emotion|🕳️|0.7|hole|坑洞 洞
Smileys & Emotion|💬|0.6|speech balloon|對話框 泡泡框 簡訊 輸入 輸入氣球
Smileys & Emotion|👁️‍🗨️|2.0|eye in speech bubble|對話框 眼睛對話框
Smileys & Emotion|🗨️|2.0|left speech bubble|對話框 黑色對話框
Smileys & Emotion|🗯️|0.7|right anger bubble|對話框 爆炸對話框
Smileys & Emotion|💭|1.0|thought balloon|對話框 心聲對話框
Smileys & Emotion|💤|0.6|ZZZ|zz 想睡 打呼 滑稽 睡了 睡著 累癱了
People & Body|👋|0.6|waving hand|再見 手 手勢 拜拜 揮手 是你嗎 該走了 閃人
People & Body|🤚|3.0|raised back of hand|反手 手 手掌 掌 豎 豎起手掌
People & Body|🖐️|0.7|hand with fingers splayed|停止 對外張開五指
People & Body|✋|0.6|raised hand|手 招手 擊掌 舉手
People & Body|🖖|1.0|vulcan salute|你好 瓦肯式敬禮 生生不息，繁榮昌盛
People & Body|🫱|14.0|rightwards hand|伸手 右 右手 向右 向右的手 手 握 握手
People & Body|🫲|14.0|leftwards hand|伸手 向左 向左的手 左 左手 手 握 握手
People & Body|🫳|14.0|palm down hand|手 手掌向下 打發 掉了 掉落 撿起 撿起來 放下 趕走
People & Body|🫴|14.0|palm up hand|不知道 來 出示 召喚 告訴我 手 手掌向上 拿 接住 給予 舉起 過來
People & Body|🫷|15.0|leftwards pushing hand|停 向左 往左，推，擊掌，阻擋，暫停，停，停止，等等，手，拒絕 手向左推 拒絕 推 擊掌 等一下
People & Body|🫸|15.0|rightwards pushing hand|停 向右 往右，推，擊掌，阻擋，暫停，停，停止，等等，手，拒絕 手向右推 拒絕 推 擊掌 等一下
People & Body|👌|0.6|OK hand|OK OK 手勢 了解 好 手指 沒問題 當然
People & Body|🤌|13.0|pinched fingers|什麼 呃 手勢 捏 捏手指 疑問 等一下 耐心 蛤 閉嘴
People & Body|🤏|12.0|pinching hand|一點點 小 少量 很少 手指 捏
People & Body|✌️|0.6|victory hand|v V 勝利 勝利手勢 耶
People & Body|🤞|3.0|crossed fingers|加油 好 祝 祝好運 運
People & Body|🫰|14.0|hand with index finger and thumb crossed|<3 彈響指 愛 愛心 手 昂貴 貴的 錢 食指和拇指交叉的手
People & Body|🤟|5.0|love-you gesture|ILY 三指 愛你 愛你手勢 我愛你 手
People & Body|🤘|1.0|sign of the horns|ROCK 手指 搖滾手勢 搖滾精神 繼續搖滾
People & Body|🤙|3.0|call me hand|打 打給我 打電話 通電話 電話
People & Body|👈|0.6|backhand index pointing left|反手 左 手 手指向左 指
People & Body|👉|0.6|backhand index pointing right|右 手 指 指向右方
People & Body|👆|0.6|backhand index pointing up|上 手 手指 手指向上 指 食指 食指向上
People & Body|🖕|1.0|middle finger|中指 比中指
People & Body|👇|0.6|backhand index pointing down|下 手 手指 指 指頭向下 食指向下
People & Body|☝️|0.6|index pointing up|提示 提醒 注意 食指
People & Body|🫵|14.0|index pointing at the viewer|你 對準 您 戳 手 手指 指 指向 食指朝向觀眾
People & Body|👍|0.6|thumbs up|OK 好棒 好耶 我喜歡 我愛 拇指 棒 正點 當然 讚
People & Body|👎|0.6|thumbs down|不可以 好爛 拇指向下 遜
People & Body|🫹|18.0|leftwards thumb sign|
People & Body|🫺|18.0|rightwards thumb sign|
People & Body|✊|0.6|raised fist|團結 拳頭 握拳 舉拳
People & Body|👊|0.6|oncoming fist|出拳 拳頭 擊拳同意 絕對贊成
People & Body|🤛|3.0|left-facing fist|右 拳 握 握右拳
People & Body|🤜|3.0|right-facing fist|左 拳 握 握左拳 握拳
People & Body|👏|0.6|clapping hands|做得好 恭賀 拍手 贊同 鼓掌
People & Body|🙌|0.6|raising hands|慶祝 歡呼 舉雙手
People & Body|🫶|14.0|heart hands|<3 愛 愛你 愛心 手 雙手心形
People & Body|👐|0.6|open hands|手 攤開手 雙手
People & Body|🤲|5.0|palms up together|合掌向上 祈禱 禱告 雙手掌朝上
People & Body|🤝|3.0|handshake|成交 手 握 握手 講定
People & Body|🙏|0.6|folded hands|感恩 感激 謝謝 阿彌陀佛 雙手合一
People & Body|✍️|0.7|writing hand|寫 手寫 書寫 記錄
People & Body|💅|0.6|nail polish|修指甲 指甲油 沒事了 無聊 美甲
People & Body|🤳|3.0|selfie|拍 相機 自 自拍
People & Body|💪|0.6|flexed biceps|二頭肌 強壯 肌肉
People & Body|🦾|12.0|mechanical arm|機械手臂 義肢 行動不便
People & Body|🦿|12.0|mechanical leg|機械腳 義肢 行動不便
People & Body|🦵|11.0|leg|四肢 曲腿 腳 腿 膝蓋 踢
People & Body|🦶|11.0|foot|腳 腳踝 跺腳 踢 踩
People & Body|👂|0.6|ear|傾聽 耳朵 聽 身體部位
People & Body|🦻|12.0|ear with hearing aid|戴助聽器的耳朵 耳聾 聽障 行動不便
People & Body|👃|0.6|nose|味道 氣味 聞到 身體部位 鼻子
People & Body|🧠|5.0|brain|大腦 聰明 腦 腦袋
People & Body|🫀|13.0|anatomical heart|器官 心 心臟 心跳 紅色 脈搏
People & Body|🫁|13.0|lungs|呼吸 器官 肺
People & Body|🦷|11.0|tooth|牙醫 牙齒 珍珠色 白色
People & Body|🦴|11.0|bone|如願骨 狗 骨架 骨頭
People & Body|👀|0.6|eyes|兩隻大眼睛 看 窺視 身體部位 雙眼
People & Body|👁️|0.7|eye|單眼 眼睛 身體部位
People & Body|👅|0.6|tongue|吸吮 舌頭 舔 身體部位
People & Body|👄|0.6|mouth|口紅 嘴唇 嘴巴 親吻 身體部位
People & Body|🫦|14.0|biting lip|不舒服 吻 咬唇 嘴唇 害怕 性感 憂慮 擔憂 焦慮 緊張
People & Body|👶|0.6|baby|初生兒 小嬰兒 小寶寶 懷孕 臉
People & Body|🧒|5.0|child|兒童 孩子 小孩
People & Body|👦|0.6|boy|男孩
People & Body|👧|0.6|girl|女孩 眼睛明亮 眼睛發光 辮子
People & Body|🧑|5.0|person|大人 成人
People & Body|👱|0.6|person: blond hair|人物 金髮 金髮人
People & Body|👨|0.6|man|兄弟 男 男人 男性 男朋友
People & Body|🧔|5.0|person: beard|大鬍男 蓄鬍的人 鬍子 鬍鬚
People & Body|🧔‍♂️|13.1|man: beard|男人 男人: 蓄鬍的人 鬍子
People & Body|🧔‍♀️|13.1|woman: beard|女人 女人: 蓄鬍的人 鬍子
People & Body|👩|0.6|woman|女 女人 女性
People & Body|👱‍♀️|4.0|woman: blond hair|女 金髮 金髮女
People & Body|👱‍♂️|4.0|man: blond hair|男 金髮 金髮男
People & Body|🧓|5.0|older person|老 老人 老男人 長者
People & Body|👴|0.6|old man|有智慧 祖父 老爺爺 老頭 臉
People & Body|👵|0.6|old woman|祖母 老太太 老奶奶
People & Body|🙍|0.6|person frowning|不爽 不高興 人物 皺眉 眉頭深鎖 表情
People & Body|🙍‍♂️|4.0|man frowning|不爽 男 男生皺眉 皺眉 表情
People & Body|🙍‍♀️|4.0|woman frowning|女 女生皺眉 皺眉 表情
People & Body|🙎|0.6|person pouting|不爽 不高興 人物 噘嘴 噘嘴的女人 生氣 生氣的人 皺眉 表情
People & Body|🙎‍♂️|4.0|man pouting|噘嘴 生氣 男生噘嘴
People & Body|🙎‍♀️|4.0|woman pouting|噘嘴 女生噘嘴 生氣
People & Body|🙅|0.6|person gesturing NO|NG 不正確 不行 人物 禁止 答錯 錯誤
People & Body|🙅‍♂️|4.0|man gesturing NO|NG 不行 叉 打叉 男生手比叉 禁止
People & Body|🙅‍♀️|4.0|woman gesturing NO|NG 不行 叉 女生手比叉 禁止
People & Body|🙆|0.6|person gesturing OK|OK OMG 人物 可以 圈 我的天 正確 答對 運動
People & Body|🙆‍♂️|4.0|man gesturing OK|OK 可以 圈 好 我的天 男生手比圈
People & Body|🙆‍♀️|4.0|woman gesturing OK|OK 可以 圈 女生手比圈
People & Body|💁|0.6|person tipping hand|人物 俏皮 分髮 嘲諷 服務台人員 服務員 給小費 髮夾
People & Body|💁‍♂️|4.0|man tipping hand|嘲諷 小費 男 男生抬手 調皮 隨便
People & Body|💁‍♀️|4.0|woman tipping hand|女 女生抬手 小費
People & Body|🙋|0.6|person raising hand|+1 你好 嗨 打招呼 舉手 舉手的人 舉手的女人 贊成 這裡 選我
People & Body|🙋‍♂️|4.0|man raising hand|作手勢 嗨 我知道 打招呼 有問題 男 男生舉手 舉手
People & Body|🙋‍♀️|4.0|woman raising hand|嗨 女 女生舉手 打招呼 舉手
People & Body|🧏|12.0|deaf person|耳朵 耳聾 聽不見 聽力 聽障人士
People & Body|🧏‍♂️|12.0|deaf man|男 聽障 聽障男子
People & Body|🧏‍♀️|12.0|deaf woman|女 聽障 聽障女子
People & Body|🙇|0.6|person bowing|下跪 不好意思 原諒 姿勢 姿態 對不起 後悔 抱歉 道歉 鞠躬
People & Body|🙇‍♂️|4.0|man bowing|不好意思 男 男生鞠躬 道歉
People & Body|🙇‍♀️|4.0|woman bowing|不好意思 女 女生鞠躬 沈思 道歉 靜思
People & Body|🤦|3.0|person facepalming|不敢相信 哦不 喔不 噢不 天啊 怎麼會 捂臉 無言 難以置信 震驚
People & Body|🤦‍♂️|4.0|man facepalming|不敢相信 喔不 噢不 天啊 完了 拜託不要 捂臉 無言 男生遮臉 難以置信
People & Body|🤦‍♀️|4.0|woman facepalming|不敢相信 喔不 噢不 天啊 女 女生遮臉 捂臉 無言 難以置信 震驚
People & Body|🤷|3.0|person shrugging|不知道 不關心 懷疑 我猜 攤手 聳 聳肩 肩 說不定 隨便
People & Body|🤷‍♂️|4.0|man shrugging|不在乎 不知道 可能 大概 應該 我猜 男 男生聳肩 聳肩 都好 隨便
People & Body|🤷‍♀️|4.0|woman shrugging|不在乎 不知道 可能 大概 女生聳肩 應該 我猜 聳肩 都好 隨便
People & Body|🧑‍⚕️|12.1|health worker|治療 護士 醫生 醫護 醫護人員
People & Body|👨‍⚕️|4.0|man health worker|男 男醫生 護士 醫生
People & Body|👩‍⚕️|4.0|woman health worker|女 女醫生 治療師 護士 醫生
People & Body|🧑‍🎓|12.1|student|學生 畢業
People & Body|👨‍🎓|4.0|man student|學生 男 男畢業生 畢業
People & Body|👩‍🎓|4.0|woman student|女 女畢業生 學生 畢業
People & Body|🧑‍🏫|12.1|teacher|教師 教授 老師
People & Body|👨‍🏫|4.0|man teacher|教授 男 男老師 老師 講師
People & Body|👩‍🏫|4.0|woman teacher|女 女老師 教授 老師 講師
People & Body|🧑‍⚖️|12.1|judge|正義 法官
People & Body|👨‍⚖️|4.0|man judge|法官 男 男法官
People & Body|👩‍⚖️|4.0|woman judge|女 女法官 法官
People & Body|🧑‍🌾|12.1|farmer|園丁 農人 農夫 農民
People & Body|👨‍🌾|4.0|man farmer|園丁 男 農夫 農民
People & Body|👩‍🌾|4.0|woman farmer|園丁 女 農婦 農民
People & Body|🧑‍🍳|12.1|cook|廚師 烹飪
People & Body|👨‍🍳|4.0|man cook|主廚 大廚 廚師 男 男廚師
People & Body|👩‍🍳|4.0|woman cook|主廚 大廚 女 女廚師 廚師
People & Body|🧑‍🔧|12.1|mechanic|修理 工人 師傅 技工
People & Body|👨‍🔧|4.0|man mechanic|技工 機械技師 男 男技工 電工 黑手
People & Body|👩‍🔧|4.0|woman mechanic|女 女技工 技工 機械技師 水管工人 黑手
People & Body|🧑‍🏭|12.1|factory worker|作業員 工廠 工廠作業員 工業 焊接
People & Body|👨‍🏭|4.0|man factory worker|作業員 工廠 工廠男作業員 男 男工人
People & Body|👩‍🏭|4.0|woman factory worker|作業員 女 工廠 工廠女作業員
People & Body|🧑‍💼|12.1|office worker|上班族 商務 白領 經理
People & Body|👨‍💼|4.0|man office worker|上班族 建築師 男 男性上班族 白領
People & Body|👩‍💼|4.0|woman office worker|上班族 女 女性上班族 白領 經理
People & Body|🧑‍🔬|12.1|scientist|化學家 工程師 物理學家 生物學家 科學家
People & Body|👨‍🔬|4.0|man scientist|化學家 工程師 數學家 物理學家 生物學家 男 男科學家 科學家
People & Body|👩‍🔬|4.0|woman scientist|化學家 女 女科學家 工程師 數學家 物理學家 科學家
People & Body|🧑‍💻|12.1|technologist|工程師 發明家 程式設計師 軟體 開發人員
People & Body|👨‍💻|4.0|man technologist|工程師 男 男工程師 發明家 程式工程師 軟體工程師
People & Body|👩‍💻|4.0|woman technologist|城市工程師 女 女工程師 工程師 軟體工程師
People & Body|🧑‍🎤|12.1|singer|搖滾 明星 歌手 演員 藝人
People & Body|👨‍🎤|4.0|man singer|搖滾 明星 歌手 男 男歌手
People & Body|👩‍🎤|4.0|woman singer|女 女歌手 搖滾 明星 歌手
People & Body|🧑‍🎨|12.1|artist|藝術家 調色盤
People & Body|👨‍🎨|4.0|man artist|男 男藝術家 藝術家 調色盤
People & Body|👩‍🎨|4.0|woman artist|女 女藝術家 藝術家 調色盤
People & Body|🧑‍✈️|12.1|pilot|機長 飛機
People & Body|👨‍✈️|4.0|man pilot|機師 機長 男 男機長 飛行員
People & Body|👩‍✈️|4.0|woman pilot|女 女機師 女機長 機長 飛行員
People & Body|🧑‍🚀|12.1|astronaut|太空人 火箭
People & Body|👨‍🚀|4.0|man astronaut|太空人 火箭人 男 男太空人
People & Body|👩‍🚀|4.0|woman astronaut|太空人 女 女太空人
People & Body|🧑‍🚒|12.1|firefighter|消防員 消防車
People & Body|👨‍🚒|4.0|man firefighter|消防員 消防車 男 男消防員
People & Body|👩‍🚒|4.0|woman firefighter|女 女消防員 消防員
People & Body|👮|0.6|police officer|執法 法律 罰單 臨檢 調查 警官 警察 警方 巡邏 逮捕
People & Body|👮‍♂️|4.0|man police officer|男 男警 警察
People & Body|👮‍♀️|4.0|woman police officer|執法 女警 法律 罰單 臨檢 調查 警官 警察 巡邏 逮捕
People & Body|🕵️|0.7|detective|偵探 間諜
People & Body|🕵️‍♂️|4.0|man detective|偵探 男 男偵探
People & Body|🕵️‍♀️|4.0|woman detective|偵探 女 女偵探
People & Body|💂|0.6|guard|憲兵 白金漢宮 衛兵
People & Body|💂‍♂️|4.0|man guard|憲兵 男 男衛兵 衛兵
People & Body|💂‍♀️|4.0|woman guard|女 女衛兵 憲兵 白金漢宮 衛兵
People & Body|🥷|13.0|ninja|刺客 士兵 忍者 戰爭 打鬥 技巧 武者 隱身
People & Body|👷|0.6|construction worker|安全帽 工地 建築工人 男人 維修 頭盔
People & Body|👷‍♂️|4.0|man construction worker|建築工人 男 男建築工人
People & Body|👷‍♀️|4.0|woman construction worker|女 女建築工人 建築工人
People & Body|🫅|14.0|person with crown|君主 國王 戴皇冠的人 王冠 王室 皇后 皇室 皇家 貴族
People & Body|🤴|3.0|prince|王 王子 皇室 皇家
People & Body|👸|0.6|princess|公主 后冠 皇冠 皇后 童話
People & Body|👳|0.6|person wearing turban|人物 戴頭巾的人 纏頭巾
People & Body|👳‍♂️|4.0|man wearing turban|戴頭巾 男 纏頭男人
People & Body|👳‍♀️|4.0|woman wearing turban|女 戴頭巾 纏頭女人 纏頭巾
People & Body|👲|0.6|person with skullcap|員外 師爺 戴瓜皮帽的人 瓜皮帽
People & Body|🧕|5.0|woman with headscarf|包頭巾的女子 披肩頭紗 面紗 頭巾 頭巾女
People & Body|🤵|3.0|person in tuxedo|新郎 正式 燕尾服 穿燕尾服的人
People & Body|🤵‍♂️|13.0|man in tuxedo|燕尾服 男人 穿燕尾服的男人
People & Body|🤵‍♀️|13.0|woman in tuxedo|女子 燕尾服 穿燕尾服的女子
People & Body|👰|0.6|person with veil|披著頭紗的人 新娘 結婚 頭紗
People & Body|👰‍♂️|13.0|man with veil|披著頭紗的男人 男人 頭紗
People & Body|👰‍♀️|13.0|woman with veil|女子 披著頭紗的女子 頭紗
People & Body|🤰|3.0|pregnant woman|孕婦 懷孕
People & Body|🫃|14.0|pregnant man|吃太飽的男人 懷孕 肚子 膨脹 臃腫 懷孕的男人
People & Body|🫄|14.0|pregnant person|吃太飽 懷孕 懷孕的人 肚子 膨脹 臃腫
People & Body|🤱|5.0|breast-feeding|乳房 哺乳 嬰兒 育嬰 餵母奶
People & Body|👩‍🍼|13.0|woman feeding baby|保姆 哺乳 媽媽 嬰兒 小北鼻 新生兒 正在哺乳的媽媽 母親 餵奶 馬麻
People & Body|👨‍🍼|13.0|man feeding baby|保姆 嬰兒 小北鼻 新生兒 正在餵奶的爸爸 父親 爸爸 男人 男性 餵奶
People & Body|🧑‍🍼|13.0|person feeding baby|保姆 哺乳 媽媽 嬰兒 小北鼻 小寶貝 新生兒 正在哺乳的人 爸爸 餵奶
People & Body|👼|0.6|baby angel|兒童 天使 孩子 小天使
People & Body|🎅|0.6|Santa Claus|爸爸 聖誕 聖誕老人 聖誕老公公
People & Body|🤶|3.0|Mrs. Claus|媽媽 童話 聖誕節 聖誕老奶奶
People & Body|🧑‍🎄|13.0|Mx Claus|節日 耶誕快樂 耶誕節 耶誕老人 聖誕 聖誕快樂 聖誕老人 跨性別聖誕老人
People & Body|🦸|11.0|superhero|正派 英雄 超人 超級英雄 超能力
People & Body|🦸‍♂️|11.0|man superhero|天賦 男人 英雄 超人 超能力
People & Body|🦸‍♀️|11.0|woman superhero|天賦 女英雄 女超人 英雄 超能力
People & Body|🦹|11.0|supervillain|壞 惡棍 犯罪 罪犯 超級反派 超級惡棍 超能力 邪惡
People & Body|🦹‍♂️|11.0|man supervillain|反派 犯罪 男人 男超級反派 超能力 邪惡
People & Body|🦹‍♀️|11.0|woman supervillain|反派 女人 女超級反派 犯罪 超能力 邪惡
People & Body|🧙|5.0|mage|巫師 男巫 著魔 魔咒 魔術師
People & Body|🧙‍♂️|5.0|man mage|男巫
People & Body|🧙‍♀️|5.0|woman mage|女巫師
People & Body|🧚|5.0|fairy|仙女 仙子 翅膀
People & Body|🧚‍♂️|5.0|man fairy|男妖精
People & Body|🧚‍♀️|5.0|woman fairy|女妖精
People & Body|🧛|5.0|vampire|吸血鬼 尖牙 毒牙 牙齒
People & Body|🧛‍♂️|5.0|man vampire|男吸血鬼
People & Body|🧛‍♀️|5.0|woman vampire|女吸血鬼
People & Body|🧜|5.0|merperson|三叉戟 人魚 傳說 塞壬 海中 海底 童話 美人魚 龍宮
People & Body|🧜‍♂️|5.0|merman|男人魚
People & Body|🧜‍♀️|5.0|mermaid|美人魚
People & Body|🧝|5.0|elf|勒苟拉斯 小精靈 魔戒風
People & Body|🧝‍♂️|5.0|man elf|男精靈
People & Body|🧝‍♀️|5.0|woman elf|女精靈
People & Body|🧞|5.0|genie|傑尼 精靈
People & Body|🧞‍♂️|5.0|man genie|藍精靈
People & Body|🧞‍♀️|5.0|woman genie|女藍精靈
People & Body|🧟|5.0|zombie|嚇人 殭屍 萬聖節 行屍走肉
People & Body|🧟‍♂️|5.0|man zombie|男殭屍
People & Body|🧟‍♀️|5.0|woman zombie|女殭屍
People & Body|🧌|14.0|troll|山怪 巨人 幻想 怪物 怪獸 戳 童話 網路白目
People & Body|🫈|17.0|hairy creature|大腳怪 大腳野人 巨大 林中野人 森林 毛茸茸 神秘 雪怪 毛怪
People & Body|💆|0.6|person getting massage|人物 做臉 按摩 放鬆 沙龍 療程 舒爽 護膚 頭痛 馬殺雞
People & Body|💆‍♂️|4.0|man getting massage|按摩 放鬆 沙龍 男 男生按摩 頭痛 馬殺雞
People & Body|💆‍♀️|4.0|woman getting massage|女 女生按摩 按摩 馬殺雞
People & Body|💇|0.6|person getting haircut|人物 剪頭髮 沙龍 理髮 美容 美髮師 設計師 造型 髮型 髮廊
People & Body|💇‍♂️|4.0|man getting haircut|剪頭髮 理髮 男 男生理髮
People & Body|💇‍♀️|4.0|woman getting haircut|剪頭髮 女 女生理髮 理髮
People & Body|🚶|0.6|person walking|人物 大搖大擺 步伐 男子走路 行人 走路 路人 踏步
People & Body|🚶‍♂️|4.0|man walking|男行人 走路 路人
People & Body|🚶‍♀️|4.0|woman walking|女行人 漫步 走路 路人 閒逛
People & Body|🚶‍➡️|15.1|person walking facing right|
People & Body|🚶‍♀️‍➡️|15.1|woman walking facing right|
People & Body|🚶‍♂️‍➡️|15.1|man walking facing right|
People & Body|🧍|12.0|person standing|人 站立 站著 站著的人
People & Body|🧍‍♂️|12.0|man standing|男 站立 站著的男子
People & Body|🧍‍♀️|12.0|woman standing|女 站立 站著的女子
People & Body|🧎|12.0|person kneeling|人 跪 跪下 跪著的人
People & Body|🧎‍♂️|12.0|man kneeling|男 跪 跪著的男子
People & Body|🧎‍♀️|12.0|woman kneeling|女 跪 跪著的女子
People & Body|🧎‍➡️|15.1|person kneeling facing right|
People & Body|🧎‍♀️‍➡️|15.1|woman kneeling facing right|
People & Body|🧎‍♂️‍➡️|15.1|man kneeling facing right|
People & Body|🧑‍🦯|12.1|person with white cane|拿導盲手杖的人 盲人 行動不便
People & Body|🧑‍🦯‍➡️|15.1|person with white cane facing right|
People & Body|👨‍🦯|12.0|man with white cane|人 拿導盲手杖的男子 男 男子 盲人 行動不便
People & Body|👨‍🦯‍➡️|15.1|man with white cane facing right|
People & Body|👩‍🦯|12.0|woman with white cane|人 女 女子 拿導盲手杖的女子 盲人 行動不便
People & Body|👩‍🦯‍➡️|15.1|woman with white cane facing right|
People & Body|🧑‍🦼|12.1|person in motorized wheelchair|坐電動輪椅的人 行動不便 輪椅
People & Body|🧑‍🦼‍➡️|15.1|person in motorized wheelchair facing right|
People & Body|👨‍🦼|12.0|man in motorized wheelchair|人 坐電動輪椅的男子 男 男子 行動不便 輪椅 電動輪椅
People & Body|👨‍🦼‍➡️|15.1|man in motorized wheelchair facing right|
People & Body|👩‍🦼|12.0|woman in motorized wheelchair|人 坐電動輪椅的女子 女 女子 行動不便 輪椅 電動輪椅
People & Body|👩‍🦼‍➡️|15.1|woman in motorized wheelchair facing right|
People & Body|🧑‍🦽|12.1|person in manual wheelchair|坐輪椅的人 行動不便 輪椅
People & Body|🧑‍🦽‍➡️|15.1|person in manual wheelchair facing right|
People & Body|👨‍🦽|12.0|man in manual wheelchair|人 坐輪椅的男子 男 男子 行動不便 輪椅
People & Body|👨‍🦽‍➡️|15.1|man in manual wheelchair facing right|
People & Body|👩‍🦽|12.0|woman in manual wheelchair|人 坐輪椅的女子 女 女子 行動不便 輪椅
People & Body|👩‍🦽‍➡️|15.1|woman in manual wheelchair facing right|
People & Body|🏃|0.6|person running|人物 快跑 移動 衝 跑步 跑者 跑過來 跑馬拉松 速度
People & Body|🏃‍♂️|4.0|man running|男 男跑者 跑 馬拉松
People & Body|🏃‍♀️|4.0|woman running|女 女跑者 跑 馬拉松
People & Body|🏃‍➡️|15.1|person running facing right|
People & Body|🏃‍♀️‍➡️|15.1|woman running facing right|
People & Body|🏃‍♂️‍➡️|15.1|man running facing right|
People & Body|🧑‍🩰|17.0|ballet dancer|舞者 芭蕾 芭蕾舞者
People & Body|💃|0.6|woman dancing|佛羅明哥 女舞者 探戈 舞者 跳舞 跳舞去
People & Body|🕺|3.0|man dancing|佛朗明哥舞 去跳舞 探戈 男 男人跳著舞 男舞者 舞 莎莎舞 跳 跳舞
People & Body|🕴️|0.7|person in suit levitating|穿著正式 穿西裝的人 西裝
People & Body|👯|0.6|people with bunny ears|兔女郎 兔耳 死黨 走趴 跳舞 閨蜜 雙胞胎 高衩
People & Body|👯‍♂️|4.0|men with bunny ears|兔耳 戴兔耳朵 跳舞 雙人兔男郎
People & Body|👯‍♀️|4.0|women with bunny ears|兔耳 跳舞 雙人兔女郎
People & Body|🧖|5.0|person in steamy room|做蒸氣浴的人 土耳其浴 桑拿 蒸汽浴
People & Body|🧖‍♂️|5.0|man in steamy room|做蒸氣浴的男子
People & Body|🧖‍♀️|5.0|woman in steamy room|做蒸氣浴的女子
People & Body|🧗|5.0|person climbing|攀岩 攀岩的人 攀岩者 攀爬 爬山
People & Body|🧗‍♂️|5.0|man climbing|攀岩男子
People & Body|🧗‍♀️|5.0|woman climbing|攀岩女子
People & Body|🤺|3.0|person fencing|擊劍 西洋劍 運動
People & Body|🏇|1.0|horse racing|賽馬 馬 騎馬
People & Body|⛷️|0.7|skier|滑雪 滑雪者
People & Body|🏂|0.6|snowboarder|滑雪 滑雪板
People & Body|🏌️|0.7|person golfing|人物 小白球 打高爾夫 揮桿 進洞 運動 高爾夫 高爾夫練習場
People & Body|🏌️‍♂️|4.0|man golfing|男 男生打高爾夫 高爾夫
People & Body|🏌️‍♀️|4.0|woman golfing|女 女生打高爾夫 高爾夫 高爾夫練習場
People & Body|🏄|0.6|person surfing|人物 水上運動 海 海灘 衝浪 衝浪板 衝浪者 運動
People & Body|🏄‍♂️|4.0|man surfing|男 男生衝浪 衝浪
People & Body|🏄‍♀️|4.0|woman surfing|女 女生衝浪 衝浪 衝浪女
People & Body|🚣|1.0|person rowing boat|人物 划船 划艇 小船 碧潭 船槳 運動
People & Body|🚣‍♂️|4.0|man rowing boat|划船 男 男生划船
People & Body|🚣‍♀️|4.0|woman rowing boat|划船 女 女生划船
People & Body|🏊|0.6|person swimming|人物 泳者 游泳 游泳選手 自由式 運動 鐵人三項
People & Body|🏊‍♂️|4.0|man swimming|游泳 男 男生游泳
People & Body|🏊‍♀️|4.0|woman swimming|女 女生游泳 游泳 運動
People & Body|⛹️|0.7|person bouncing ball|人物 打球 比賽 球 籃球 罰球 運動 運動員 運球 選手
People & Body|⛹️‍♂️|4.0|man bouncing ball|球 男 男生打球
People & Body|⛹️‍♀️|4.0|woman bouncing ball|女 女生打球 打籃球 玩彈力球 球
People & Body|🏋️|0.7|person lifting weights|人物 健身 槓片 槓鈴 舉重 運動 重訓 重量訓練
People & Body|🏋️‍♂️|4.0|man lifting weights|男 男生舉重 舉重
People & Body|🏋️‍♀️|4.0|woman lifting weights|女 女生舉重 舉重 鍛鍊
People & Body|🚴|1.0|person biking|單車 腳踏車 自由車 自行車 自行車騎士 運動 鐵馬 騎登山車 騎自行車 騎車
People & Body|🚴‍♂️|4.0|man biking|男 男自行車手 腳踏車 自行車 騎車
People & Body|🚴‍♀️|4.0|woman biking|女 女自行車手 腳踏車 自行車 騎腳踏車 騎車
People & Body|🚵|1.0|person mountain biking|單車 登山車 腳踏車 自行車 自行車騎士 運動 鐵馬 騎登山車 騎自行車 騎車
People & Body|🚵‍♂️|4.0|man mountain biking|男 男登山車手 登山車
People & Body|🚵‍♀️|4.0|woman mountain biking|女 女登山車手 登山車
People & Body|🤸|3.0|person cartwheeling|倒立 側翻 活潑 筋斗 興奮 跟斗 運動 運動員 開心 體操
People & Body|🤸‍♂️|4.0|man cartwheeling|倒立 活潑 筋斗 翻跟斗 興奮 跟斗 運動 運動員 開心 體操 男生側翻
People & Body|🤸‍♀️|4.0|woman cartwheeling|倒立 活潑 筋斗 翻跟斗 興奮 跟斗 運動 運動員 開心 體操 女生側翻
People & Body|🤼|3.0|people wrestling|單挑 拼了 搏鬥 摔角 摔角手 比賽 競賽 角力 運動員 釘孤枝
People & Body|🤼‍♂️|4.0|men wrestling|單挑 拼了 搏鬥 摔角 比賽 男子摔角 競賽 角力 運動員 釘孤枝
People & Body|🤼‍♀️|4.0|women wrestling|單挑 女子摔角 拼了 搏鬥 摔角 比賽 競賽 角力 運動員 釘孤枝
People & Body|🤽|3.0|person playing water polo|人物 水上 水球 水球運動 游泳 運動
People & Body|🤽‍♂️|4.0|man playing water polo|人物 水球 游泳 男 男生打水球 運動
People & Body|🤽‍♀️|4.0|woman playing water polo|人物 女 女生打水球 水球 游泳 運動
People & Body|🤾|3.0|person playing handball|丟球 人物 手球 扔 投擲 接 球類 運動 運動員
People & Body|🤾‍♂️|4.0|man playing handball|手球 男 男生打手球
People & Body|🤾‍♀️|4.0|woman playing handball|丟球 人物 女 女生打手球 手球 扔 投擲 接 運動 運動員
People & Body|🤹|3.0|person juggling|人物 多才多藝 平衡 平衡感 技藝 特技 表演 雜耍
People & Body|🤹‍♂️|4.0|man juggling|人物 多才多藝 平衡 男 男生玩雜耍 表演 雜耍
People & Body|🤹‍♀️|4.0|woman juggling|多工處理 女 女生玩雜耍 雜耍
People & Body|🧘|5.0|person in lotus position|冥想 打坐 放鬆 瑜珈 盤坐 盤腿 蓮花座 靜坐
People & Body|🧘‍♂️|5.0|man in lotus position|盤坐男子
People & Body|🧘‍♀️|5.0|woman in lotus position|盤坐女子
People & Body|🛀|0.6|person taking bath|洗澡 盆浴
People & Body|🛌|1.0|person in bed|夜裡 打瞌睡 旅館 晚安 睡眠時 睡覺 要睡著了
People & Body|🧑‍🤝‍🧑|12.0|people holding hands|人 情侶 握手 握手的人 牽手 牽手的人 牽牽
People & Body|👭|1.0|women holding hands|LGBT 兩個女人 兩個女人手拉手 女兒 女朋友 好朋友 姐妹 姐妹淘 手拉手
People & Body|👫|0.6|woman and man holding hands|一男一女 一男一女手拉手 手拉手 相戀 約會 調情
People & Body|👬|1.0|men holding hands|LGBT 兩個男人 兩個男人手拉手 手拉手 雙胞胎
People & Body|💏|0.6|kiss|女朋友 寶貝 愛情 接吻 男朋友 約會 親
People & Body|👩‍❤️‍💋‍👨|2.0|kiss: woman, man|
People & Body|👨‍❤️‍💋‍👨|2.0|kiss: man, man|
People & Body|👩‍❤️‍💋‍👩|2.0|kiss: woman, woman|
People & Body|💑|0.6|couple with heart|一對 男女 相愛
People & Body|👩‍❤️‍👨|2.0|couple with heart: woman, man|
People & Body|👨‍❤️‍👨|2.0|couple with heart: man, man|
People & Body|👩‍❤️‍👩|2.0|couple with heart: woman, woman|
People & Body|👨‍👩‍👦|2.0|family: man, woman, boy|
People & Body|👨‍👩‍👧|2.0|family: man, woman, girl|
People & Body|👨‍👩‍👧‍👦|2.0|family: man, woman, girl, boy|
People & Body|👨‍👩‍👦‍👦|2.0|family: man, woman, boy, boy|
People & Body|👨‍👩‍👧‍👧|2.0|family: man, woman, girl, girl|
People & Body|👨‍👨‍👦|2.0|family: man, man, boy|
People & Body|👨‍👨‍👧|2.0|family: man, man, girl|
People & Body|👨‍👨‍👧‍👦|2.0|family: man, man, girl, boy|
People & Body|👨‍👨‍👦‍👦|2.0|family: man, man, boy, boy|
People & Body|👨‍👨‍👧‍👧|2.0|family: man, man, girl, girl|
People & Body|👩‍👩‍👦|2.0|family: woman, woman, boy|
People & Body|👩‍👩‍👧|2.0|family: woman, woman, girl|
People & Body|👩‍👩‍👧‍👦|2.0|family: woman, woman, girl, boy|
People & Body|👩‍👩‍👦‍👦|2.0|family: woman, woman, boy, boy|
People & Body|👩‍👩‍👧‍👧|2.0|family: woman, woman, girl, girl|
People & Body|👨‍👦|4.0|family: man, boy|
People & Body|👨‍👦‍👦|4.0|family: man, boy, boy|
People & Body|👨‍👧|4.0|family: man, girl|
People & Body|👨‍👧‍👦|4.0|family: man, girl, boy|
People & Body|👨‍👧‍👧|4.0|family: man, girl, girl|
People & Body|👩‍👦|4.0|family: woman, boy|
People & Body|👩‍👦‍👦|4.0|family: woman, boy, boy|
People & Body|👩‍👧|4.0|family: woman, girl|
People & Body|👩‍👧‍👦|4.0|family: woman, girl, boy|
People & Body|👩‍👧‍👧|4.0|family: woman, girl, girl|
People & Body|🗣️|0.7|speaking head|剪影 說話 說話的人影
People & Body|👤|0.6|bust in silhouette|剪影 神秘 肖像剪影 陰影
People & Body|👥|1.0|busts in silhouette|剪影 朋友 每個人 雙人肖像剪影
People & Body|🫂|13.0|people hugging|再見 友情 安慰 愛 抱抱 掰掰 擁抱 擁抱的人 謝謝 道別
People & Body|👪|0.6|family|家庭 親子
People & Body|🧑‍🧑‍🧒|15.1|family: adult, adult, child|家庭：兩大一小
People & Body|🧑‍🧑‍🧒‍🧒|15.1|family: adult, adult, child, child|家庭：兩大兩小
People & Body|🧑‍🧒|15.1|family: adult, child|家庭：一大一小
People & Body|🧑‍🧒‍🧒|15.1|family: adult, child, child|家庭：一大兩小
People & Body|👣|0.6|footprints|在路上 腳印 裸足 赤腳 足跡
People & Body|🫆|16.0|fingerprint|安全 指紋 法醫 身份
Animals & Nature|🐵|0.6|monkey face|動物 猴 猴子頭
Animals & Nature|🐒|0.6|monkey|動物 猴 猴子 香蕉
Animals & Nature|🦍|3.0|gorilla|動物 大猩猩 猩猩
Animals & Nature|🦧|12.0|orangutan|人猿 動物 猩猩 猴子
Animals & Nature|🐶|0.6|dog face|寵物 小狗 狗 狗臉 狗頭
Animals & Nature|🐕|0.7|dog|動物 狗
Animals & Nature|🦮|12.0|guide dog|導盲 導盲犬 視障 行動不便
Animals & Nature|🐕‍🦺|12.0|service dog|服務 服務犬 狗 行動不便 輔助
Animals & Nature|🐩|0.6|poodle|捲毛狗 貴賓犬 貴賓狗
Animals & Nature|🐺|0.6|wolf|動物 狼 狼面
Animals & Nature|🦊|3.0|fox|動物 狐狸
Animals & Nature|🦝|11.0|raccoon|好奇 浣熊 淘氣 狡猾
Animals & Nature|🐱|0.6|cat face|動物 貓 貓頭
Animals & Nature|🐈|0.7|cat|小貓 貓
Animals & Nature|🐈‍⬛|13.0|black cat|不幸 動物 喵 萬聖節 貓 貓咪 黑 黑色 黑貓
Animals & Nature|🦁|1.0|lion|獅 獅子 獅子座
Animals & Nature|🐯|0.6|tiger face|巧虎 老虎頭 虎 虎面
Animals & Nature|🐅|1.0|tiger|動物 掠食動物 老虎 虎
Animals & Nature|🐆|1.0|leopard|花豹 豹 豹子
Animals & Nature|🐴|0.6|horse face|動物 盛裝馬術 馬 馬術 馬頭
Animals & Nature|🫎|15.0|moose|動物 哺乳動物 駝鹿 麋 麋鹿 麋鹿，動物，角，駝鹿，麋，哺乳類
Animals & Nature|🫏|15.0|donkey|傻子 動物 哺乳動物 白癡 笨蛋 頑固 騾 驢 驢子 驢子，動物，騾子，驢子，固執，哺乳類
Animals & Nature|🐎|0.6|horse|動物 賽馬 馬 馬術
Animals & Nature|🦄|1.0|unicorn|獨角獸
Animals & Nature|🦓|5.0|zebra|動物 斑馬 條紋
Animals & Nature|🦌|3.0|deer|動物 鹿
Animals & Nature|🦬|13.0|bison|動物 水牛 牧群 野牛
Animals & Nature|🐮|0.6|cow face|牛 牛頭
Animals & Nature|🐂|1.0|ox|公牛 動物 牛 金牛座
Animals & Nature|🐃|1.0|water buffalo|動物 水牛 牛
Animals & Nature|🐄|1.0|cow|乳牛 動物 牛
Animals & Nature|🐷|0.6|pig face|豬 豬頭
Animals & Nature|🐖|1.0|pig|動物 培根 豬 豬肉
Animals & Nature|🐗|0.6|boar|動物 豬 野豬
Animals & Nature|🐽|0.6|pig nose|豬鼻子
Animals & Nature|🐏|1.0|ram|公羊 動物 白羊座 羊
Animals & Nature|🐑|0.6|ewe|動物 毛茸茸 綿羊 羊 羊毛
Animals & Nature|🐐|1.0|goat|動物 山羊 摩羯座 羊
Animals & Nature|🐪|1.0|camel|動物 單峰駱駝 駱駝
Animals & Nature|🐫|0.6|two-hump camel|動物 雙峰駱駝 雙蜂駱駝 駱駝
Animals & Nature|🦙|11.0|llama|動物 小羊駝 毛 羊毛 羊駝 羊駝毛 美野生羊駝
Animals & Nature|🦒|5.0|giraffe|長頸鹿
Animals & Nature|🐘|0.6|elephant|大象 象
Animals & Nature|🦣|13.0|mammoth|動物 巨大 毛象 猛瑪象 絕種 象牙 長毛象
Animals & Nature|🦏|3.0|rhinoceros|動物 犀牛
Animals & Nature|🦛|11.0|hippopotamus|動物 河馬
Animals & Nature|🐭|0.6|mouse face|動物 老鼠頭 耗子 鼠
Animals & Nature|🐁|1.0|mouse|動物 小老鼠 耗子 鼠
Animals & Nature|🐀|1.0|rat|動物 老鼠 耗子 鼠
Animals & Nature|🐹|0.6|hamster|倉鼠 寵物鼠
Animals & Nature|🐰|0.6|rabbit face|兔 兔子臉 兔子頭 動物
Animals & Nature|🐇|1.0|rabbit|兔 兔子 動物
Animals & Nature|🐿️|0.7|chipmunk|松鼠 花栗鼠
Animals & Nature|🦫|13.0|beaver|動物 水壩 海狸 牙
Animals & Nature|🦔|5.0|hedgehog|刺蝟 多刺
Animals & Nature|🦇|3.0|bat|吸血 蝙蝠
Animals & Nature|🐻|0.6|bear|動物 熊 熊面
Animals & Nature|🐻‍❄️|13.0|polar bear|北極熊 極地 熊 白色
Animals & Nature|🐨|0.6|koala|無尾熊
Animals & Nature|🐼|0.6|panda|熊貓 貓熊
Animals & Nature|🦥|12.0|sloth|慢 懶 懶散 樹懶
Animals & Nature|🦦|12.0|otter|好玩 水獺 釣魚
Animals & Nature|🦨|12.0|skunk|臭 臭鼬
Animals & Nature|🦘|11.0|kangaroo|動物 小袋鼠 有袋動物 有袋目 澳洲 袋鼠 跳
Animals & Nature|🦡|11.0|badger|動物 獾 糾纏 蜜獾
Animals & Nature|🐾|0.6|paw prints|動物腳印 足跡
Animals & Nature|🦃|1.0|turkey|感恩節 火雞
Animals & Nature|🐔|0.6|chicken|動物 雞
Animals & Nature|🐓|1.0|rooster|公雞 動物 雞
Animals & Nature|🐣|0.6|hatching chick|孵化 小雞破蛋
Animals & Nature|🐤|0.6|baby chick|小雞 小雞的臉
Animals & Nature|🐥|0.6|front-facing baby chick|小雞 正面小雞
Animals & Nature|🐦|0.6|bird|動物 鳥 鳥類學
Animals & Nature|🐧|0.6|penguin|企鵝 南極
Animals & Nature|🕊️|0.7|dove|和平鴿 飛鳥 鳥 鴿子
Animals & Nature|🦅|3.0|eagle|動物 老鷹 鳥
Animals & Nature|🦆|3.0|duck|鳥 鴨 鴨子
Animals & Nature|🦢|11.0|swan|動物 天鵝 小天鵝 醜小鴨 鳥
Animals & Nature|🦉|3.0|owl|動物 智慧 有智慧 貓頭應 貓頭鷹 鳥
Animals & Nature|🦤|13.0|dodo|動物 巨鳥 模里西斯 渡渡鳥 絕種 鳥
Animals & Nature|🪶|13.0|feather|羽毛 輕 飄 飛
Animals & Nature|🦩|12.0|flamingo|熱帶 紅鶴 鮮豔
Animals & Nature|🦚|11.0|peacock|動物 孔雀 孔雀開屏 賣弄 雌孔雀 驕傲 鳥
Animals & Nature|🦜|11.0|parrot|海盜 說話 講話 鳥 鸚鵡
Animals & Nature|🪽|15.0|wing|天使 神話 翅膀 翼，翅膀，天使，升天，天堂，飛，神話，飛行 飛翔 飛行 鳥
Animals & Nature|🐦‍⬛|15.0|black bird|渡鴉 烏鴉 烏鴉，喙，渡鴉，黑色，鴉叫聲，呱呱，鳥，動物 白嘴鴉 鳥 黑 黑鳥
Animals & Nature|🪿|15.0|goose|傻瓜 呆子 家禽 愚蠢 糊塗 飛禽 鳥 鵝 鵝，傻，鴨，雄鵝，鵝群，鴨群，家禽，鳥，動物 鵝叫聲
Animals & Nature|🐦‍🔥|15.1|phoenix|上升 不死 幻想 榮耀 浴火重生 火鳥 燃燒 轉變 重生 鳳凰
Animals & Nature|🐸|0.6|frog|蛙 青蛙
Animals & Nature|🐊|1.0|crocodile|動物 鱷 鱷魚
Animals & Nature|🐢|0.6|turtle|烏龜 龜
Animals & Nature|🦎|3.0|lizard|爬行動物 蜥蜴
Animals & Nature|🐍|0.6|snake|蛇 蛇夫座 青蛇
Animals & Nature|🐲|0.6|dragon face|動物 神話故事 龍 龍頭
Animals & Nature|🐉|1.0|dragon|中國龍 動物 權力遊戲 龍
Animals & Nature|🦕|5.0|sauropod|恐龍 梁龍 蜥腳類恐龍 長頸巨龍 雷龍
Animals & Nature|🦖|5.0|T-Rex|恐龍 暴龍 雷克斯暴龍 霸王龍
Animals & Nature|🐳|0.6|spouting whale|噴水 鯨魚 鯨魚噴水
Animals & Nature|🐋|1.0|whale|藍鯨 鯨
Animals & Nature|🐬|0.6|dolphin|動物 海豚
Animals & Nature|🫍|17.0|orca|大洋 大海 海洋 鯨 鯨魚 虎鯨
Animals & Nature|🦭|13.0|seal|動物 海洋 海獅 海豹
Animals & Nature|🐟|0.6|fish|動物 雙魚座 魚
Animals & Nature|🐠|0.6|tropical fish|熱帶魚 魚
Animals & Nature|🐡|0.6|blowfish|河豚 魚
Animals & Nature|🦈|3.0|shark|動物 魚 鯊魚
Animals & Nature|🐙|0.6|octopus|八爪魚 章魚
Animals & Nature|🐚|0.6|spiral shell|動物 海螺 螺旋貝殼 貝殼
Animals & Nature|🪸|14.0|coral|氣候變遷 海 海洋 珊瑚 珊瑚礁 礁 礁石
Animals & Nature|🪼|15.0|jellyfish|好痛 果凍 果醬 水母 水母，海洋，觸鬚，蜉蝣生物，水族館，海，海洋，海洋生物，螫，動物 海生 灼痛感 無脊椎動物 蜇人 針刺
Animals & Nature|🦀|1.0|crab|巨蟹座 紅蟳 螃蟹 蟹
Animals & Nature|🦞|11.0|lobster|海鮮 海鮮濃湯 濃湯 爪 紅龍蝦 鉗 龍蝦
Animals & Nature|🦐|3.0|shrimp|甲殼 蝦 蝦子 食物
Animals & Nature|🦑|3.0|squid|軟體動物 食物 魷魚
Animals & Nature|🦪|12.0|oyster|潛水 牡蠣 珍珠
Animals & Nature|🐌|0.6|snail|蝸牛
Animals & Nature|🦋|3.0|butterfly|昆蟲 美 蝴蝶
Animals & Nature|🫌|18.0|monarch butterfly|
Animals & Nature|🐛|0.6|bug|毛毛蟲 毛蟲
Animals & Nature|🐜|0.6|ant|動物 螞蟻 蟻
Animals & Nature|🐝|0.6|honeybee|動物 春天 蜂 蜜蜂
Animals & Nature|🪲|13.0|beetle|動物 昆蟲 甲蟲 蟲 金龜子
Animals & Nature|🐞|0.6|lady beetle|昆蟲 瓢蟲
Animals & Nature|🦗|5.0|cricket|直翅目 蚱蜢 蟋蟀 蟲子
Animals & Nature|🪳|13.0|cockroach|動物 噁心 小強 昆蟲 蟑螂
Animals & Nature|🕷️|0.7|spider|蜘蛛
Animals & Nature|🕸️|0.7|spider web|網狀 蛛網 蜘蛛 蜘蛛網
Animals & Nature|🦂|1.0|scorpion|天蠍座 蠍 蠍子
Animals & Nature|🦟|11.0|mosquito|疾病 病毒 瘧疾 發燒 蚊子 蟲 蟲咬 蟲子
Animals & Nature|🪰|13.0|fly|動物 昆蟲 腐爛 舌蠅 蒼蠅 馬蠅
Animals & Nature|🪱|13.0|worm|動物 寄生蟲 環節動物 蚯蚓 蟲 蠕蟲
Animals & Nature|🦠|11.0|microbe|微生物 濾過性病毒 病毒 細菌 阿米巴
Animals & Nature|💐|0.6|bouquet|浪漫 花束 週年 鮮花
Animals & Nature|🌸|0.6|cherry blossom|櫻花 花
Animals & Nature|💮|0.6|white flower|白花 花
Animals & Nature|🪷|14.0|lotus|佛教 印度 印度教 寧靜 平和 平靜 純潔 花 蓮花 越南
Animals & Nature|🏵️|0.7|rosette|玫瑰花圖案 花 花朵
Animals & Nature|🌹|0.6|rose|玫瑰 紅玫瑰 花
Animals & Nature|🥀|3.0|wilted flower|凋零 枯萎 枯萎花朵 花
Animals & Nature|🌺|0.6|hibiscus|芙蓉 花
Animals & Nature|🌻|0.6|sunflower|向日葵 花
Animals & Nature|🌼|0.6|blossom|花 蒲公英 開花
Animals & Nature|🌷|0.6|tulip|花 鬱金香
Animals & Nature|🪻|15.0|hyacinth|矢車菊 羽扇豆 花 薰衣草 金魚藻 風信子 風信子，紫色，花苞，春天，紫羅蘭，靛藍，紫丁香，薰衣草，植物，花，羽扇豆 魯冰花
Animals & Nature|🌱|0.6|seedling|幼苗 發芽 苗
Animals & Nature|🪴|13.0|potted plant|室內植物 植物 生長 盆景 盆栽 裝飾 觀賞
Animals & Nature|🌲|1.0|evergreen tree|常青樹 松樹 樹 聖誕樹
Animals & Nature|🌳|1.0|deciduous tree|樹 落葉樹
Animals & Nature|🌴|0.6|palm tree|棕櫚樹 樹 熱帶
Animals & Nature|🌵|0.6|cactus|乾旱 仙人掌 多肉植物 沙漠
Animals & Nature|🌾|0.6|sheaf of rice|水稻 稻子 穀物 米
Animals & Nature|🌿|0.6|herb|植物 草藥 葉子 香草
Animals & Nature|☘️|1.0|shamrock|三葉草 愛爾蘭 草
Animals & Nature|🍀|0.6|four leaf clover|四 四葉草 幸運草 愛爾蘭
Animals & Nature|🍁|0.6|maple leaf|楓葉 紅葉 落葉
Animals & Nature|🍂|0.6|fallen leaf|枯葉 秋葉 落葉
Animals & Nature|🍃|0.6|leaf fluttering in wind|隨風飄落的葉子 風吹葉落
Animals & Nature|🪹|14.0|empty nest|家 樹枝 空巢 築巢 鳥巢
Animals & Nature|🪺|14.0|nest with eggs|有蛋的巢 樹枝 築巢 蛋 鳥 鳥巢
Animals & Nature|🍄|0.6|mushroom|蕈類 蘑菇 香菇
Animals & Nature|🪾|16.0|leafless tree|乾旱 光禿禿的樹 冬天 貧瘠 沒有葉子的樹
Food & Drink|🍇|0.6|grapes|水果 葡萄
Food & Drink|🍈|0.6|melon|哈密瓜 水果 瓜 甜瓜 蜜瓜 香瓜
Food & Drink|🍉|0.6|watermelon|水果 西瓜
Food & Drink|🍊|0.6|tangerine|橘子 水果
Food & Drink|🍋|1.0|lemon|檸檬 水果
Food & Drink|🍋‍🟩|15.1|lime|果汁 柑橘、水果、熱帶 柑橘類 檸檬 水果 清爽 熱帶 維他命 C 萊姆 酸 雞尾酒 食物
Food & Drink|🍌|0.6|banana|水果 鉀 香蕉
Food & Drink|🍍|0.6|pineapple|水果 熱帶水果 鳳梨
Food & Drink|🥭|11.0|mango|水果 熱帶 芒果
Food & Drink|🍎|0.6|red apple|水果 紅蘋果 蘋果
Food & Drink|🍏|0.6|green apple|水果 蘋果 青蘋果
Food & Drink|🍐|1.0|pear|梨子 水果
Food & Drink|🍑|0.6|peach|桃子 水果
Food & Drink|🍒|0.6|cherries|櫻桃 水果
Food & Drink|🍓|0.6|strawberry|水果 草莓
Food & Drink|🫐|13.0|blueberries|水果 漿果 莓 莓果 藍莓 食物
Food & Drink|🥝|3.0|kiwi fruit|奇異果 水果 食物
Food & Drink|🍅|0.6|tomato|水果 番茄 蔬果
Food & Drink|🫒|13.0|olive|橄欖 食物
Food & Drink|🥥|5.0|coconut|棕櫚 椰子 鳳梨椰汁蘭姆酒
Food & Drink|🥑|3.0|avocado|水果 酪梨 食物
Food & Drink|🍆|0.6|eggplant|茄子 蔬菜
Food & Drink|🥔|3.0|potato|根莖類 蔬菜 食物 馬鈴薯
Food & Drink|🥕|3.0|carrot|根莖類 紅蘿蔔 胡蘿蔔 蔬菜 食物
Food & Drink|🌽|0.6|ear of corn|玉米 蔬菜
Food & Drink|🌶️|0.7|hot pepper|蔬菜 辣椒
Food & Drink|🫑|13.0|bell pepper|甜椒 蔬菜 辣椒 青椒 食物
Food & Drink|🥒|3.0|cucumber|小黃瓜 蔬菜 食物 黃瓜
Food & Drink|🫝|18.0|pickle|
Food & Drink|🥬|11.0|leafy green|小白菜 沙拉 甘藍菜 綠色葉菜 綠葉蔬菜 羽衣甘藍 萵苣 高麗菜
Food & Drink|🥦|5.0|broccoli|綠花椰菜 花椰菜 西蘭花 青花菜
Food & Drink|🧄|12.0|garlic|大蒜 調味 調味料
Food & Drink|🧅|12.0|onion|洋蔥 調味 調味料
Food & Drink|🥜|3.0|peanuts|堅果 花生 蔬菜 食物
Food & Drink|🫘|14.0|beans|小 腰子 豆 豆子 豆類 食物
Food & Drink|🌰|0.6|chestnut|杏仁 栗子
Food & Drink|🫚|15.0|ginger root|啤酒 根 薑 薑，根，香料，香草，大自然，健康，啤酒 調味品 辛辣 香料
Food & Drink|🫛|15.0|pea pod|毛豆 蔬菜 豆子 豆子，豆莢，毛豆，蔬菜，豆莖，菜，黃豆，豆類，豆 豆莢 豆類 豌豆 豌豆莢
Food & Drink|🍄‍🟫|15.1|brown mushroom|松露 棕色蕈菇 素食 菇 蕈類 蘑菇 食物 食物、真菌、自然、蔬菜 香菇
Food & Drink|🫜|16.0|root vegetable|根 甜菜 花園 蔬菜 蘿蔔 根莖類蔬菜
Food & Drink|🍞|0.6|bread|全穀物 吐司 醣類 麵包
Food & Drink|🥐|3.0|croissant|可頌 法式 牛角麵包 麵包
Food & Drink|🥖|3.0|baguette bread|法國麵包 法式 食物 麵包
Food & Drink|🫓|13.0|flatbread|印度南餅 圓麵餅 扁麵包 玉米麵包 糕餅 薄麵包 食物 餅 麵包 麵餅
Food & Drink|🥨|5.0|pretzel|彎曲 椒鹽卷餅 椒鹽捲餅 盤繞 糾結 蝴蝶餅
Food & Drink|🥯|11.0|bagel|早餐 硬麵包圈 貝果 醬 麵包
Food & Drink|🥞|3.0|pancakes|煎餅 薄餅 食物 鬆餅
Food & Drink|🧇|12.0|waffle|早餐 格子鬆餅 楓糖 無法決定 猶豫不決 鐵 鬆餅
Food & Drink|🧀|1.0|cheese wedge|乳酪 起士
Food & Drink|🍖|0.6|meat on bone|帶骨肉 排骨
Food & Drink|🍗|0.6|poultry leg|帶骨肉 雞腿
Food & Drink|🥩|5.0|cut of meat|牛扒 牛排 紅肉 羊排 肉片 肉類 豬排
Food & Drink|🥓|3.0|bacon|培根 肉類 食物
Food & Drink|🍔|0.6|hamburger|漢堡 漢堡包 餓了
Food & Drink|🍟|0.6|french fries|炸薯條 薯條 速食
Food & Drink|🍕|0.6|pizza|披薩 義大利辣肉腸 起士披薩
Food & Drink|🌭|1.0|hot dog|熱狗 熱狗堡 香腸
Food & Drink|🥪|5.0|sandwich|三明治 麵包
Food & Drink|🌮|1.0|taco|夾餅 墨西哥夾餅
Food & Drink|🌯|1.0|burrito|捲餅 墨西哥捲餅
Food & Drink|🫔|13.0|tamale|捲餅 玉米粉蒸肉 食物 墨西哥 墨西哥粽
Food & Drink|🥙|3.0|stuffed flatbread|炸豆丸子 薄捲餅 食物
Food & Drink|🧆|12.0|falafel|油炸鷹嘴豆餅 肉丸 雪蓮子 鷹嘴豆
Food & Drink|🥚|3.0|egg|蛋 雞蛋 食物
Food & Drink|🍳|0.6|cooking|煎蛋 荷包蛋
Food & Drink|🥘|3.0|shallow pan of food|平底鍋 料理 法國砂鍋 淺鍋 淺鍋料理 烤鍋 烤鍋料理
Food & Drink|🍲|0.6|pot of food|火鍋 燉菜
Food & Drink|🫕|13.0|fondue|乳酪 巧克力 涮製菜餚 滑雪 瑞士 融化 起司 起司火鍋 鍋 食物
Food & Drink|🥣|5.0|bowl with spoon|早餐 早餐穀物 湯匙與碗 燕麥 碗和湯匙 粥 餐具
Food & Drink|🥗|3.0|green salad|沙拉 生菜 生菜沙拉 食物
Food & Drink|🍿|1.0|popcorn|爆米花 看電影
Food & Drink|🧈|12.0|butter|乳製品 奶油
Food & Drink|🧂|11.0|salt|佐料 火大 調味品 調味瓶 鹽
Food & Drink|🥫|5.0|canned food|罐頭 罐頭食品 罐頭食物
Food & Drink|🍱|0.6|bento box|便當 餐盒
Food & Drink|🍘|0.6|rice cracker|仙貝 米果 米食
Food & Drink|🍙|0.6|rice ball|飯糰
Food & Drink|🍚|0.6|cooked rice|煮熟的米飯 米飯 飯
Food & Drink|🍛|0.6|curry rice|咖哩飯 飯
Food & Drink|🍜|0.6|steaming bowl|湯麵 熱麵碗 筷子 麵
Food & Drink|🍝|0.6|spaghetti|義大利麵 肉醬麵 麵
Food & Drink|🍠|0.6|roasted sweet potato|地瓜 烤地瓜
Food & Drink|🍢|0.6|oden|海鮮串 烤肉串 關東煮
Food & Drink|🍣|0.6|sushi|壽司
Food & Drink|🍤|0.6|fried shrimp|天婦羅 炸蝦 蝦
Food & Drink|🍥|0.6|fish cake with swirl|魚板
Food & Drink|🥮|11.0|moon cake|中秋 中秋節 月餅 秋天
Food & Drink|🍡|0.6|dango|丸子串 糥米丸串 糥米丸子
Food & Drink|🥟|5.0|dumpling|水餃 餃子
Food & Drink|🥠|5.0|fortune cookie|幸運餅乾 簽餅 語言
Food & Drink|🥡|5.0|takeout box|中市外賣盒 外帶餐盒 外賣 筷子 送便當 送餐 飯盒
Food & Drink|🍦|0.6|soft ice cream|冰品 冰淇淋 霜淇淋
Food & Drink|🍧|0.6|shaved ice|冰品 刨 刨冰
Food & Drink|🍨|0.6|ice cream|冰品 冰淇淋 甜品
Food & Drink|🍩|0.6|doughnut|甜甜圈 甜點
Food & Drink|🍪|0.6|cookie|巧克力餅乾 甜點 餅乾
Food & Drink|🎂|0.6|birthday cake|慶祝 生日 生日快樂 生日蛋糕 蛋糕
Food & Drink|🍰|0.6|shortcake|甜點 蛋糕
Food & Drink|🧁|11.0|cupcake|杯子蛋糕 杯蛋糕 烘焙 甜點 糕點
Food & Drink|🥧|5.0|pie|一片派 南瓜派 派 糕點 肉派 蘋果派 西點 餡
Food & Drink|🍫|0.6|chocolate bar|巧克力 巧克力棒 巧克力磚
Food & Drink|🍬|0.6|candy|萬聖節 糖 糖果 糖果紙
Food & Drink|🍭|0.6|lollipop|棒棒糖 糖果
Food & Drink|🍮|0.6|custard|卡士達 布丁 甜點
Food & Drink|🍯|0.6|honey pot|甜點 蜂蜜 蜂蜜罐
Food & Drink|🍼|1.0|baby bottle|奶瓶 牛奶
Food & Drink|🥛|3.0|glass of milk|一杯牛奶 杯 牛奶 飲料
Food & Drink|☕|0.6|hot beverage|咖啡 星巴克 熱飲 茶 飲料
Food & Drink|🫖|13.0|teapot|壺 泡茶 茶 茶壺 食物 飲品
Food & Drink|🍵|0.6|teacup without handle|無柄茶杯 熱茶 茶 茶杯
Food & Drink|🍶|0.6|sake|喝清酒 清酒 酒
Food & Drink|🍾|1.0|bottle with popping cork|洋酒 酒
Food & Drink|🍷|0.6|wine glass|紅酒 葡萄酒 酒 酒杯
Food & Drink|🍸|0.6|cocktail glass|酒 酒杯 雞尾酒 馬提尼
Food & Drink|🍹|0.6|tropical drink|果汁 熱帶水果果汁 熱帶水果飲料
Food & Drink|🍺|0.6|beer mug|啤酒 啤酒節 酒
Food & Drink|🍻|0.6|clinking beer mugs|乾杯 乾杯吧 碰杯 酒
Food & Drink|🥂|3.0|clinking glasses|乾杯 慶祝 碰杯 舉杯
Food & Drink|🥃|3.0|tumbler glass|威士忌 威士忌杯 烈酒 玻璃杯 酒杯
Food & Drink|🫗|14.0|pouring liquid|倒 倒出液體 倒空 哎呀 意外 水 流出 流空 灑出 玻璃杯
Food & Drink|🥤|5.0|cup with straw|吸管杯 杯子和吸管 果汁 水 汽水 飲料 麥芽飲料
Food & Drink|🧋|13.0|bubble tea|台灣 手搖 珍奶 珍珠 珍珠奶茶 茶 食物 飲料
Food & Drink|🧃|12.0|beverage box|吸管 果汁 甜 鋁箔包 飲料
Food & Drink|🧉|12.0|mate|瑪黛茶 飲料
Food & Drink|🧊|12.0|ice|冰 冰塊 冰山 冷
Food & Drink|🥢|5.0|chopsticks|筷子
Food & Drink|🍽️|0.7|fork and knife with plate|刀叉餐盤 餐具 餐盤
Food & Drink|🍴|0.6|fork and knife|刀叉 午餐 吃 吃飯 好吃 早餐 晚餐 美味 食物 餐廳
Food & Drink|🥄|3.0|spoon|吃 湯匙 餐具
Food & Drink|🔪|0.6|kitchen knife|刀 菜刀
Food & Drink|🫙|14.0|jar|容器 廣口瓶 果醬 沒有東西 空瓶 空的 罐子 調味品 貯存品
Food & Drink|🏺|1.0|amphora|容器 陶罐
Travel & Places|🌍|0.7|globe showing Europe-Africa|地球 歐洲 歐洲及非洲 歐非 非洲
Travel & Places|🌎|0.7|globe showing Americas|地球 美洲
Travel & Places|🌏|0.6|globe showing Asia-Australia|亞洲 亞洲及澳洲 亞澳 地球 澳洲
Travel & Places|🌐|1.0|globe with meridians|地球 子午線
Travel & Places|🗺️|0.7|world map|世界 世界地圖 地圖
Travel & Places|🗾|0.6|map of Japan|日本 日本列島
Travel & Places|🧭|11.0|compass|定向 導航 指南針 方向 磁鐵 羅盤
Travel & Places|🏔️|0.7|snow-capped mountain|雪山 雪峰
Travel & Places|⛰️|0.7|mountain|山 山峰
Travel & Places|🛘|17.0|landslide|危險 土石流 地震 山 岩石 災難 雪崩 山崩
Travel & Places|🌋|0.6|volcano|火山 火山爆發
Travel & Places|🗻|0.6|mount fuji|富士山 山峰
Travel & Places|🏕️|0.7|camping|帳篷露營 露營 露營帳篷
Travel & Places|🏖️|0.7|beach with umbrella|海灘 海灘陽傘
Travel & Places|🏜️|0.7|desert|沙漠
Travel & Places|🏝️|0.7|desert island|沙漠 沙灘小島 熱帶小島
Travel & Places|🏞️|0.7|national park|公園 國家公園
Travel & Places|🏟️|0.7|stadium|球場 競技場 運動場 體育場 體育館
Travel & Places|🏛️|0.7|classical building|古典建築 古蹟
Travel & Places|🏗️|0.7|building construction|施工 施工中
Travel & Places|🧱|11.0|brick|泥土 灰泥 灰漿 牆 牆壁 磚 磚塊
Travel & Places|🪨|13.0|rock|岩石 巨石 巨礫 石材 石頭 硬
Travel & Places|🪵|13.0|wood|木塊 木料 木材 木頭
Travel & Places|🛖|13.0|hut|圓頂帳篷 家 小屋 房屋 茅屋
Travel & Places|🏘️|0.7|houses|屋舍 房屋建築
Travel & Places|🏚️|0.7|derelict house|廢墟 荒宅
Travel & Places|🏠|0.6|house|家 房子 郊區
Travel & Places|🏡|0.6|house with garden|別墅 家 有庭院的家 郊區
Travel & Places|🏢|0.6|office building|市區 辦公大樓 都市 高樓大廈
Travel & Places|🏣|0.6|Japanese post office|日本郵局 郵局
Travel & Places|🏤|1.0|post office|歐洲郵局 郵局
Travel & Places|🏥|0.6|hospital|醫生 醫療 醫藥 醫院
Travel & Places|🏦|0.6|bank|銀行
Travel & Places|🏨|0.6|hotel|旅館 飯店
Travel & Places|🏩|0.6|love hotel|汽車旅館 賓館
Travel & Places|🏪|0.6|convenience store|24 小時便利店 便利商店
Travel & Places|🏫|0.6|school|學校 校舍
Travel & Places|🏬|0.6|department store|百貨公司 購物商場
Travel & Places|🏭|0.6|factory|工廠 廠房
Travel & Places|🏯|0.6|Japanese castle|城堡 日式城堡
Travel & Places|🏰|0.6|castle|城堡 歐式城堡
Travel & Places|💒|0.6|wedding|婚禮 教堂婚禮
Travel & Places|🗼|0.6|Tokyo tower|東京鐵塔 鐵塔
Travel & Places|🗽|0.6|Statue of Liberty|紐約 自由女神 自由女神像
Travel & Places|⛪|0.6|church|十字架 基督教 教堂
Travel & Places|🕌|1.0|mosque|伊斯蘭建築 清真寺
Travel & Places|🛕|12.0|hindu temple|印度 印度廟 廟
Travel & Places|🕍|1.0|synagogue|教堂 猶太教 猶太教堂
Travel & Places|⛩️|0.7|shinto shrine|宗教 神社 鳥居
Travel & Places|🕋|1.0|kaaba|伊斯蘭建築 天房 朝覲
Travel & Places|⛲|0.6|fountain|噴水池 噴泉
Travel & Places|⛺|0.6|tent|帳篷 露營
Travel & Places|🌁|0.6|foggy|天氣 霧
Travel & Places|🌃|0.6|night with stars|夜晚 星夜 星空
Travel & Places|🏙️|0.7|cityscape|城市 天際線 都市風景
Travel & Places|🌄|0.6|sunrise over mountains|日出 黎明
Travel & Places|🌅|0.6|sunrise|旭日 朝陽
Travel & Places|🌆|0.6|cityscape at dusk|建築物 暮色 黃昏
Travel & Places|🌇|0.6|sunset|夕陽 建築物 日落
Travel & Places|🌉|0.6|bridge at night|夜景 夜橋 橋
Travel & Places|♨️|0.6|hot springs|泡湯 溫泉 熱氣
Travel & Places|🎠|0.6|carousel horse|旋轉木馬
Travel & Places|🛝|14.0|playground slide|主題樂園 溜滑梯 玩樂 遊樂場 遊玩
Travel & Places|🎡|0.6|ferris wheel|摩天輪 遊樂區
Travel & Places|🎢|0.6|roller coaster|雲霄飛車
Travel & Places|💈|0.6|barber pole|修面 刮鬍 理髮 理髮店
Travel & Places|🎪|0.6|circus tent|帳篷 馬戲團 馬戲團帳篷
Travel & Places|🚂|1.0|locomotive|火車 蒸汽火車
Travel & Places|🚃|0.6|railway car|有軌電車 軌道電車
Travel & Places|🚄|0.6|high-speed train|新幹線 火車 高鐵
Travel & Places|🚅|0.6|bullet train|子彈列車 火車 高鐡車頭 高鐵
Travel & Places|🚆|1.0|train|到站 火車 鐵道
Travel & Places|🚇|0.6|metro|地鐵 捷運
Travel & Places|🚈|1.0|light rail|抵達 捷運 火車 輕軌 鐵道
Travel & Places|🚉|0.6|station|捷運 車站 鐵路
Travel & Places|🚊|1.0|tram|捷運 路面電車 軌道電車
Travel & Places|🚝|1.0|monorail|單軌 火車
Travel & Places|🚞|1.0|mountain railway|山區鐵路 火車
Travel & Places|🚋|1.0|tram car|電纜車 電車
Travel & Places|🚌|0.6|bus|公共汽車 公車
Travel & Places|🚍|0.7|oncoming bus|公共汽車 公車
Travel & Places|🚎|1.0|trolleybus|公車 無軌電車 電動巴士
Travel & Places|🚐|1.0|minibus|小型巴士 小巴
Travel & Places|🚑|0.6|ambulance|救護車
Travel & Places|🚒|0.6|fire engine|消防車
Travel & Places|🚓|0.6|police car|警車
Travel & Places|🚔|0.7|oncoming police car|警察車 警車
Travel & Places|🚕|0.6|taxi|小黃 計程車
Travel & Places|🚖|1.0|oncoming taxi|優步 小黃 計程車
Travel & Places|🚗|0.6|automobile|汽車 轎車
Travel & Places|🚘|0.7|oncoming automobile|汽車 轎車
Travel & Places|🚙|0.6|sport utility vehicle|休旅車
Travel & Places|🛻|13.0|pickup truck|交通工具 卡車 敞篷小貨車 汽車 皮卡 皮卡車 貨卡
Travel & Places|🚚|0.6|delivery truck|卡車 貨車
Travel & Places|🚛|1.0|articulated lorry|卡車 貨車
Travel & Places|🚜|1.0|tractor|拖弋機 拖拉機
Travel & Places|🏎️|0.7|racing car|賽車
Travel & Places|🏍️|0.7|motorcycle|摩托車 機車
Travel & Places|🛵|3.0|motor scooter|摩托車 機車
Travel & Places|🦽|12.0|manual wheelchair|行動不便 輪椅
Travel & Places|🦼|12.0|motorized wheelchair|行動不便 電動輪椅
Travel & Places|🛺|12.0|auto rickshaw|嘟嘟車 電動式人力車
Travel & Places|🚲|0.6|bicycle|腳踏車 自行車
Travel & Places|🛴|3.0|kick scooter|滑板車 滑行
Travel & Places|🛹|11.0|skateboard|滑板 直排輪
Travel & Places|🛼|13.0|roller skate|單排輪 溜冰 溜冰鞋 滑輪 直排輪 輪式溜冰鞋 運動
Travel & Places|🚏|0.6|bus stop|公車站 公車站牌
Travel & Places|🛣️|0.7|motorway|公路 道路 高速公路
Travel & Places|🛤️|0.7|railway track|鐵軌 鐵道
Travel & Places|🛢️|0.7|oil drum|油桶 石油
Travel & Places|⛽|0.6|fuel pump|加油 加油幫浦 加油站
Travel & Places|🛞|14.0|wheel|圓圈 車 車輛 輪子 輪胎 轉動
Travel & Places|🚨|0.6|police car light|急救 警察 警車燈
Travel & Places|🚥|0.6|horizontal traffic light|交通號誌 紅綠燈
Travel & Places|🚦|1.0|vertical traffic light|交通號誌 十字路口 直式紅綠燈 紅綠燈
Travel & Places|🛑|3.0|stop sign|停止 停止標誌 八角形 標誌
Travel & Places|🚧|0.6|construction|工地 施工 施工中
Travel & Places|🛙|18.0|lighthouse|
Travel & Places|⚓|0.6|anchor|船錨 錨
Travel & Places|🛟|14.0|ring buoy|保命工具 安全 救援 救生 救生圈 救生用具 浮具 浮標 游泳
Travel & Places|⛵|0.6|sailboat|帆船 遊艇
Travel & Places|🛶|3.0|canoe|獨木舟 船
Travel & Places|🚤|0.6|speedboat|快艇
Travel & Places|🛳️|0.7|passenger ship|客船 客輪 船
Travel & Places|⛴️|0.7|ferry|客船 渡輪 船
Travel & Places|🛥️|0.7|motor boat|汽艇 船
Travel & Places|🚢|0.6|ship|船
Travel & Places|✈️|0.6|airplane|噴射機 旅行 飛機
Travel & Places|🛩️|0.7|small airplane|小型飛機 小飛機 私人飛機
Travel & Places|🛫|1.0|airplane departure|出境 登機 起飛 飛機 飛機起飛
Travel & Places|🛬|1.0|airplane arrival|降落 飛機著陸
Travel & Places|🪂|12.0|parachute|懸掛式滑翔 拖曳傘 滑翔翼 跳傘 降落傘
Travel & Places|💺|0.6|seat|座位 座椅
Travel & Places|🚁|1.0|helicopter|直升機
Travel & Places|🚟|1.0|suspension railway|懸掛式單軌鐵路 懸掛鐵路 懸索鐵路 空鐵
Travel & Places|🚠|1.0|mountain cableway|纜車
Travel & Places|🚡|1.0|aerial tramway|空中纜車 纜車
Travel & Places|🛰️|0.7|satellite|太空 衛星
Travel & Places|🚀|0.6|rocket|火箭
Travel & Places|🛸|5.0|flying saucer|UFO 外太空人 外星人 幽浮 異形 飛碟
Travel & Places|🛎️|0.7|bellhop bell|服務鈴
Travel & Places|🧳|11.0|luggage|手提箱 打包 旅行 滑輪行李箱 行李
Travel & Places|⌛|0.6|hourglass done|沙漏
Travel & Places|⏳|0.6|hourglass not done|沙漏 流動的沙漏 等待
Travel & Places|⌚|0.6|watch|手錶 錶
Travel & Places|⏰|0.6|alarm clock|時鐘 鬧鐘
Travel & Places|⏱️|1.0|stopwatch|時鐘 碼錶
Travel & Places|⏲️|1.0|timer clock|時鐘 計時器
Travel & Places|🕰️|0.7|mantelpiece clock|座鐘 時鐘
Travel & Places|🕛|0.6|twelve o’clock|十二點 午夜 正午
Travel & Places|🕧|0.7|twelve-thirty|十二點半
Travel & Places|🕐|0.6|one o’clock|一點
Travel & Places|🕜|0.7|one-thirty|一點半 時鐘 時間
Travel & Places|🕑|0.6|two o’clock|兩點
Travel & Places|🕝|0.7|two-thirty|兩點半
Travel & Places|🕒|0.6|three o’clock|三點
Travel & Places|🕞|0.7|three-thirty|三點半
Travel & Places|🕓|0.6|four o’clock|四點
Travel & Places|🕟|0.7|four-thirty|四點半
Travel & Places|🕔|0.6|five o’clock|五點
Travel & Places|🕠|0.7|five-thirty|五點半
Travel & Places|🕕|0.6|six o’clock|六點
Travel & Places|🕡|0.7|six-thirty|六點半
Travel & Places|🕖|0.6|seven o’clock|七點
Travel & Places|🕢|0.7|seven-thirty|七點半
Travel & Places|🕗|0.6|eight o’clock|八點
Travel & Places|🕣|0.7|eight-thirty|八點半
Travel & Places|🕘|0.6|nine o’clock|九點
Travel & Places|🕤|0.7|nine-thirty|九點半
Travel & Places|🕙|0.6|ten o’clock|十點
Travel & Places|🕥|0.7|ten-thirty|十點半
Travel & Places|🕚|0.6|eleven o’clock|十一點
Travel & Places|🕦|0.7|eleven-thirty|十一點半
Travel & Places|🌑|0.6|new moon|新月 月亮 朔月
Travel & Places|🌒|1.0|waxing crescent moon|彎月 眉形新月
Travel & Places|🌓|0.6|first quarter moon|上弦月 月亮
Travel & Places|🌔|0.6|waxing gibbous moon|月亮 盈凸月
Travel & Places|🌕|0.6|full moon|月亮 望月 滿月
Travel & Places|🌖|1.0|waning gibbous moon|漸盈月 虧凸月
Travel & Places|🌗|1.0|last quarter moon|下弦月 月亮
Travel & Places|🌘|1.0|waning crescent moon|殘月 眉形殘月
Travel & Places|🌙|0.6|crescent moon|彎月 新月 月亮 月牙 残月
Travel & Places|🌚|1.0|new moon face|新月臉 月亮 月亮公公 朔月
Travel & Places|🌛|0.6|first quarter moon face|上弦月 彎月臉朝左 月亮 眉月
Travel & Places|🌜|0.7|last quarter moon face|下弦月 彎月臉朝右 月亮
Travel & Places|🌡️|0.7|thermometer|溫度計
Travel & Places|☀️|0.6|sun|太陽 明亮 晴天 晴朗 陽光
Travel & Places|🌝|1.0|full moon face|微笑的滿月 月亮
Travel & Places|🌞|1.0|sun with face|太陽 微笑的太陽
Travel & Places|🪐|12.0|ringed planet|土星 土星環 帶行星環的行星
Travel & Places|⭐|0.6|star|星星 白色中型星
Travel & Places|🌟|0.6|glowing star|星星 閃爍的星星
Travel & Places|🌠|0.6|shooting star|星星 星空 流星
Travel & Places|🌌|0.6|milky way|星空 銀河
Travel & Places|☁️|0.6|cloud|天氣 有雲 陰天 雲
Travel & Places|⛅|0.6|sun behind cloud|天氣 陰天
Travel & Places|⛈️|0.7|cloud with lightning and rain|天氣 暴風雨 雷雨 風暴
Travel & Places|🌤️|0.7|sun behind small cloud|天氣 晴偶有雲
Travel & Places|🌥️|0.7|sun behind large cloud|多雲到晴 天氣 晴時多雲
Travel & Places|🌦️|0.7|sun behind rain cloud|天氣 晴時有雨
Travel & Places|🌧️|0.7|cloud with rain|天氣 雨天
Travel & Places|🌨️|0.7|cloud with snow|下雪 天氣 有雲有雪
Travel & Places|🌩️|0.7|cloud with lightning|天氣 有雲有雷電 閃電
Travel & Places|🌪️|0.7|tornado|天氣 旋風 龍捲風
Travel & Places|🌫️|0.7|fog|天氣 有霧 雲 霧
Travel & Places|🌬️|0.7|wind face|刮風 吹風 天氣
Travel & Places|🌀|0.6|cyclone|天氣 暈 氣旋 颱風
Travel & Places|🌈|0.6|rainbow|同性 彩虹 跨性別 雙性
Travel & Places|🌂|0.6|closed umbrella|傘 收合的傘 雨傘
Travel & Places|☂️|0.7|umbrella|下雨 傘 雨傘
Travel & Places|☔|0.6|umbrella with rain drops|下雨 傘 雨中的傘
Travel & Places|⛱️|0.7|umbrella on ground|傘 遮陽傘
Travel & Places|⚡|0.6|high voltage|閃電 雷電 電 高壓電
Travel & Places|❄️|0.6|snowflake|下雪 雪花
Travel & Places|☃️|0.7|snowman|雪中的雪人 雪人
Travel & Places|⛄|0.6|snowman without snow|沒雪的雪人 雪人
Travel & Places|☄️|1.0|comet|慧星
Travel & Places|🪋|18.0|meteor|
Travel & Places|🔥|0.6|fire|火 火焰 火苗
Travel & Places|💧|0.6|droplet|水滴 汗 淚 眼淚
Travel & Places|🌊|0.6|water wave|波浪 海浪 神奈川 衝浪
Activities|🎃|0.6|jack-o-lantern|南瓜 南瓜燈 萬聖節
Activities|🎄|0.6|Christmas tree|聖誕樹 聖誕節
Activities|🎆|0.6|fireworks|慶典 焰火 煙花 爆竹
Activities|🎇|0.6|sparkler|火紅 焰火 煙花
Activities|🧨|11.0|firecracker|火花 火藥 炸藥 煙火 爆炸 爆竹 爆裂物 鞭炮
Activities|✨|0.6|sparkles|閃亮 閃爍 閃耀 魔術
Activities|🎈|0.6|balloon|慶祝 氣球 生日
Activities|🎉|0.6|party popper|太棒了 慶祝 拉炮
Activities|🎊|0.6|confetti ball|五彩紙屑 彩球 慶祝
Activities|🎋|0.6|tanabata tree|七夕 七夕樹 樹
Activities|🎍|0.6|pine decoration|盆栽 開運竹
Activities|🎎|0.6|Japanese dolls|女兒節 日本娃娃 雛祭
Activities|🎏|0.6|carp streamer|鯉魚旗
Activities|🎐|0.6|wind chime|風鈴
Activities|🎑|0.6|moon viewing ceremony|賞月
Activities|🧧|11.0|red envelope|利事 吉利 壓歲錢 好兆頭 好運 禮物 禮金 紅包 紅包袋 錢
Activities|🎀|0.6|ribbon|彩帶 絲帶 蝴蝶結
Activities|🎁|0.6|wrapped gift|慶祝 生日禮物 禮物 禮盒
Activities|🎗️|0.7|reminder ribbon|絲帶 黃絲帶
Activities|🎟️|0.7|admission tickets|入場券 票券
Activities|🎫|0.6|ticket|入場券 票券 票根 門票
Activities|🎖️|0.7|military medal|勳章 軍事獎章
Activities|🏆|0.6|trophy|冠軍 勝利 獎座 獎盃 獲勝 競賽 贏了
Activities|🏅|1.0|sports medal|獎牌 獲勝 金牌
Activities|🥇|3.0|1st place medal|冠軍 第一名 金牌
Activities|🥈|3.0|2nd place medal|亞軍 第二名 銀牌
Activities|🥉|3.0|3rd place medal|季軍 第三名 銅牌
Activities|⚽|0.6|soccer ball|球 足球 運動
Activities|⚾|0.6|baseball|打球 棒球 球 運動
Activities|🥎|11.0|softball|低手 壘球 手套 球 運動
Activities|🏀|0.6|basketball|球 籃球
Activities|🏐|1.0|volleyball|排球 球 球賽
Activities|🏈|0.6|american football|球 美式足球 超級盃
Activities|🏉|1.0|rugby football|橄欖球 球 美式足球
Activities|🎾|0.6|tennis|球 球拍 網球 運動
Activities|🥏|11.0|flying disc|極限 飛盤
Activities|🎳|0.6|bowling|保齡球 全倒 球
Activities|🏏|1.0|cricket game|板球 球
Activities|🏑|1.0|field hockey|曲棍球 曲棍球桿 球
Activities|🏒|1.0|ice hockey|冰上曲棍球 球
Activities|🥍|11.0|lacrosse|得分 球 球桿 球棍 袋棍球 運動 長曲棍球
Activities|🏓|1.0|ping pong|乒乒 乒乓 乒乓球 桌球 球 球拍
Activities|🏸|1.0|badminton|球 羽毛球 羽球
Activities|🥊|3.0|boxing glove|手套 拳擊 拳擊手套 競技 運動
Activities|🥋|3.0|martial arts uniform|柔道 武術 空手道 競技 跆拳道 運動 道服
Activities|🥅|3.0|goal net|球網 球門 運動
Activities|⛳|0.6|flag in hole|旗桿 高爾夫
Activities|⛸️|0.7|ice skate|溜冰 溜冰鞋 滑冰
Activities|🎣|0.6|fishing pole|釣竿 釣魚 釣魚竿
Activities|🤿|12.0|diving mask|水肺 水肺潛水 浮潛 潛水 潛水面罩
Activities|🎽|0.6|running shirt|運動 運動服 運動衫 飾帶
Activities|🎿|0.6|skis|滑雪
Activities|🛷|5.0|sled|平底雪橇 滑雪橇 雪橇
Activities|🥌|5.0|curling stone|冰上溜石 冰壺 冰石壺 石塊 石頭 遊戲
Activities|🎯|0.6|bullseye|命中 正中紅心
Activities|🪀|12.0|yo-yo|搖擺不定 溜溜球 滾動 玩具
Activities|🪁|12.0|kite|上升 放風箏 風箏 飛
Activities|🔫|0.6|water pistol|手槍 槍 武器 水槍
Activities|🎱|0.6|pool 8 ball|8 八 八號球 撞球 球
Activities|🔮|0.6|crystal ball|占卜 水晶球 算命
Activities|🪄|13.0|magic wand|巫婆 巫師 魔杖 魔法 魔術 魔術師
Activities|🎮|0.6|video game|xbox 遙控器 電動 電玩
Activities|🕹️|0.7|joystick|搖桿 操控桿 電玩
Activities|🎰|0.6|slot machine|吃角子老虎 拉霸機 賭博 賭場
Activities|🎲|0.6|game die|擲骰子 骰子
Activities|🧩|11.0|puzzle piece|拼 拼圖 片 益智遊戲 相扣 線索 謎題
Activities|🧸|11.0|teddy bear|填充 填充玩具 娃娃 毛茸茸 泰迪熊 玩具 玩具熊 玩物 長毛絨
Activities|🪅|13.0|piñata|五月節 慶祝 派對 皮納塔 節慶 糖果 墨西哥
Activities|🪩|14.0|mirror ball|派對 球 發光 跳舞 迪斯可 鏡子 鏡面球
Activities|🪆|13.0|nesting dolls|俄羅斯 俄羅斯娃娃 多層 娃娃
Activities|♠️|0.6|spade suit|撲克牌 紙牌 花色 黑桃
Activities|♥️|0.6|heart suit|紅心 紙牌
Activities|♦️|0.6|diamond suit|方塊 牌局 紙牌 鑽石
Activities|♣️|0.6|club suit|梅花 紙牌
Activities|♟️|11.0|chess pawn|卒 戰略 棋子 鬥智
Activities|🃏|0.6|joker|外卡 小丑 皇牌 鬼牌
Activities|🀄|0.6|mahjong red dragon|紅中 麻將
Activities|🎴|0.6|flower playing cards|花牌 花鬥
Activities|🎭|0.6|performing arts|戲劇 演員 面具
Activities|🖼️|0.7|framed picture|畫 畫框 裱框畫
Activities|🎨|0.6|artist palette|畫畫 調色板 調色盤
Activities|🧵|11.0|thread|線 線卷 線軸 縫紉 裁縫 針 針線
Activities|🪡|13.0|sewing needle|刺繡 線 縫 縫紉 縫衣針 裁縫針 針 針線
Activities|🧶|11.0|yarn|毛線 毛線球 球 編織 織 針織 鉤針 鉤針編織
Activities|🪢|13.0|knot|交織 打結 細繩 結 繩結
Objects|👓|0.6|glasses|眼鏡
Objects|🕶️|0.7|sunglasses|太陽眼鏡 暗色 墨鏡
Objects|🥽|11.0|goggles|保護眼睛 游泳 潛水 焊工 蛙鏡 護目鏡
Objects|🥼|11.0|lab coat|上衣 實驗 實驗服 實驗袍 科學家 衣服 醫生
Objects|🦺|12.0|safety vest|安全 救生衣 緊急狀況 背心
Objects|👔|0.6|necktie|工作 正式 領帶
Objects|👕|0.6|t-shirt|T卹 T恤 上衣 衣服 襯衫
Objects|👖|0.6|jeans|丹寧褲 休閒 牛仔褲 褲子 週末打扮
Objects|🧣|5.0|scarf|包得緊緊 圍巾 圍脖 好冷 脖子 領巾 頸子 頸巾
Objects|🧤|5.0|gloves|手 手套
Objects|🧥|5.0|coat|冷 包得緊緊 外套 夾克 好冷
Objects|🧦|5.0|socks|絲襪 襪子
Objects|👗|0.6|dress|洋裝 血拼 裙子
Objects|👘|0.6|kimono|和服 日本 舒服
Objects|🥻|12.0|sari|洋裝 莎麗服 衣服
Objects|🩱|12.0|one-piece swimsuit|一件式泳裝 泳衣 泳裝
Objects|🩲|12.0|briefs|一件式 內衣 泳裝 泳褲 短褲
Objects|🩳|12.0|shorts|內衣 泳裝 泳褲 短泳褲 短褲 褲裝
Objects|👙|0.6|bikini|三點式 比基尼 海灘 游泳 游泳池
Objects|👚|0.6|woman’s clothes|女裝 女襯衫 血拼 衣服
Objects|🪭|15.0|folding hand fan|害羞 扇子 扇子，降溫，調情，跳舞，害羞，拍手，搧，熱 摺扇 擺動 涼快 熱 舞蹈
Objects|👛|0.6|purse|手提包 荷包 錢包
Objects|👜|0.6|handbag|包包 手提包 血拼
Objects|👝|0.6|clutch bag|包包 手拿包 手提包
Objects|🛍️|0.7|shopping bags|紙袋 購物袋
Objects|🎒|0.6|backpack|書包 肩揹書包 背包
Objects|🩴|13.0|thong sandal|人字拖 拖鞋 沙灘涼鞋 海灘鞋 涼鞋 草鞋 鞋
Objects|👞|0.6|man’s shoe|咖啡色 皮鞋 血拼 鞋
Objects|👟|0.6|running shoe|球鞋 跑鞋 踢 運動鞋
Objects|🥾|11.0|hiking boot|健行 戶外 登山靴 背包 露營 靴子 鞋子
Objects|🥿|11.0|flat shoe|平底鞋 懶人鞋 拖鞋 淺口便鞋 無帶便鞋 舒服 芭蕾舞鞋
Objects|👠|0.6|high-heeled shoe|女鞋 細高跟鞋 血拼 高跟鞋
Objects|👡|0.6|woman’s sandal|拖鞋 涼鞋
Objects|🩰|12.0|ballet shoes|舞 芭蕾 芭蕾舞鞋
Objects|👢|0.6|woman’s boot|女靴 長靴 靴子
Objects|🪮|15.0|hair pick|梳子 梳子，梳，頭髮，打扮，蓬髮 梳理 非洲式髮型 頭髮
Objects|👑|0.6|crown|后冠 皇冠 皇家 皇族
Objects|👒|0.6|woman’s hat|帽子 庭園派對 淑女帽
Objects|🎩|0.6|top hat|禮帽 紳士帽 變魔術 魔術
Objects|🎓|0.6|graduation cap|學士帽 畢業 畢業帽
Objects|🧢|5.0|billed cap|便帽 大嘴帽 彎簷帽 棒球帽 爸爸帽 鴨舌帽
Objects|🪖|13.0|military helmet|士兵 安全帽 戰爭 戰鬥 軍人 軍隊 陸軍 頭盔
Objects|⛑️|0.7|rescue worker’s helmet|安全帽 工程安全帽
Objects|📿|1.0|prayer beads|祈禱 項鍊 首飾
Objects|💄|0.6|lipstick|化妝 化妝品 口紅 打扮
Objects|💍|0.6|ring|戒指 結婚 訂婚 鑽戒 鑽石 閃亮
Objects|💎|0.6|gem stone|婚禮 寶石 訂婚 鑽石
Objects|🔇|1.0|muted speaker|關掉喇叭 關掉聲音 静音
Objects|🔈|0.7|speaker low volume|低音量 喇叭
Objects|🔉|1.0|speaker medium volume|中音 低音量 喇叭
Objects|🔊|0.6|speaker high volume|喇叭 揚聲器 聲音 高音量
Objects|📢|0.6|loudspeaker|喇叭 大聲公
Objects|📣|0.6|megaphone|喇叭 擴音器
Objects|📯|1.0|postal horn|號角 通知 郵件通知
Objects|🔔|0.6|bell|下課 鈴鐺 鐘聲
Objects|🔕|1.0|bell with slash|無聲 靜音
Objects|🎼|0.6|musical score|樂譜 音樂 音符
Objects|🎵|0.6|musical note|音樂 音符
Objects|🎶|0.6|musical notes|樂符 音樂
Objects|🎙️|0.7|studio microphone|錄音室 錄音室麥克風 麥克風
Objects|🎚️|0.7|level slider|滑桿 調整桿
Objects|🎛️|0.7|control knobs|控制旋鈕 旋鈕
Objects|🎤|0.6|microphone|k歌 卡拉OK 唱歌 麥克風
Objects|🎧|0.6|headphone|耳機 聲音 音樂
Objects|📻|0.6|radio|收音機
Objects|🎷|0.6|saxophone|樂器 薩克斯風
Objects|🎺|0.6|trumpet|小號 樂器
Objects|🪊|17.0|trombone|傷心 悲傷 樂器 滑管 爵士樂 銅管樂器 難過 音樂 長號
Objects|🪗|13.0|accordion|六角手風琴 手風琴 樂器 音樂
Objects|🎸|0.6|guitar|吉他 樂器 電吉他
Objects|🎹|0.6|musical keyboard|樂器 鋼琴 鍵盤樂器 電子琴
Objects|🎻|0.6|violin|小提琴 樂器
Objects|🪕|12.0|banjo|弦樂器 斑鳩琴 樂器 音樂
Objects|🥁|3.0|drum|打擊樂 音樂 鼓 鼓棒 鼓槌
Objects|🪘|13.0|long drum|小鼓 康加舞 康加鼓 打擊 樂器 節奏 長鼓 鼓
Objects|🪇|15.0|maracas|搖動 敲擊 樂器 沙球，跳舞，趴踢，宴會，搖，恰恰，音樂，樂器，敲擊樂器，打擊樂 沙鈴 音樂 響聲
Objects|🪈|15.0|flute|木管樂器 橫笛 直笛 管樂器 豎笛 長笛 長笛，木管樂，長笛手，樂隊，樂儀隊，短笛，管弦樂團，管樂器，豎笛，音樂，橫笛，樂器 音樂
Objects|🪉|16.0|harp|丘比特 愛 樂器 樂團 豎琴 音樂
Objects|📱|0.6|mobile phone|手機 行動電話 電話
Objects|📲|0.6|mobile phone with arrow|手機 接電話 電話
Objects|☎️|0.6|telephone|市話 電話
Objects|📞|0.6|telephone receiver|聽筒 電話
Objects|📟|0.6|pager|BB call 呼叫器
Objects|📠|0.6|fax machine|FAX 傳真機
Objects|🔋|0.6|battery|電池
Objects|🪫|14.0|low battery|低電力 低電量 耗盡 電 電池 電量不足
Objects|🔌|0.6|electric plug|插頭 電力
Objects|💻|0.6|laptop|個人電腦 筆記型電腦 筆電
Objects|🖥️|0.7|desktop computer|桌上型電腦 桌機 電腦 顯示器
Objects|🖨️|0.7|printer|列表機 印表機
Objects|⌨️|1.0|keyboard|鍵盤 電腦
Objects|🖱️|0.7|computer mouse|滑鼠 電腦 電腦滑鼠
Objects|🖲️|0.7|trackball|軌跡球
Objects|💽|0.6|computer disk|光碟 迷你光碟
Objects|💾|0.6|floppy disk|磁碟片
Objects|💿|0.6|optical disk|CD 光碟 硬碟 藍光
Objects|📀|0.6|dvd|DVD 光碟 藍光
Objects|🧮|11.0|abacus|演算 算盤 計算 計算機
Objects|🎥|0.6|movie camera|寶萊塢 攝影機 電影 電影攝影機
Objects|🎞️|0.7|film frames|影片 膠卷 電影膠卷
Objects|📽️|0.7|film projector|影片 放映機 電影 電影放映機
Objects|🎬|0.6|clapper board|場記板 開麥拉
Objects|📺|0.6|television|電視
Objects|📷|0.6|camera|相機
Objects|📸|1.0|camera with flash|帶閃光燈的相機 拍照 開閃光燈
Objects|📹|0.6|video camera|攝影機 攝錄影機 錄影
Objects|📼|0.6|videocassette|VHS 卡帶 錄影帶
Objects|🔍|0.6|magnifying glass tilted left|向左的放大鏡 搜尋 放大鏡
Objects|🔎|0.6|magnifying glass tilted right|享有的放大鏡 搜尋 放大 放大鏡
Objects|🕯️|0.7|candle|光亮 蠟燭
Objects|💡|0.6|light bulb|燈泡
Objects|🔦|0.6|flashlight|手電筒
Objects|🏮|0.6|red paper lantern|居酒屋 燈籠 紅燈籠
Objects|🪔|12.0|diya lamp|油 油燈 燈 陶碗 陶碗油燈
Objects|📔|0.6|notebook with decorative cover|彩色封面的筆記本 筆記本
Objects|📕|0.6|closed book|合起來的書本 書本
Objects|📖|0.6|open book|小說 打開來的書本 書本 知識 讀書 閱讀
Objects|📗|0.6|green book|圖書館 書本 綠色的書本
Objects|📘|0.6|blue book|書本 藍色的書本
Objects|📙|0.6|orange book|書本 橘色的書本
Objects|📚|0.6|books|書 書本 書籍
Objects|📓|0.6|notebook|筆記本
Objects|📒|0.6|ledger|帳本 帳簿 筆記本
Objects|📃|0.6|page with curl|捲起的頁面 文件 文件檔 文書
Objects|📜|0.6|scroll|捲軸 文書 紙張
Objects|📄|0.6|page facing up|文件 文書 文檔
Objects|📰|0.6|newspaper|報紙 新聞
Objects|🗞️|0.7|rolled-up newspaper|報紙 捲好的報紙 捲起 新聞
Objects|📑|0.6|bookmark tabs|分頁標籤 標籤 頁籤
Objects|🔖|0.6|bookmark|書籤
Objects|🏷️|0.7|label|吊牌 標籤
Objects|🪙|13.0|coin|寶藏 歐元 硬幣 金 金屬 金幣 銀 錢 錢幣
Objects|💰|0.6|money bag|一桶金 錢 錢袋
Objects|🪎|17.0|treasure chest|寶石 戰利品 搶劫 珠寶 財富 貴重物品 金子 銀 錢 藏寶箱
Objects|💴|0.6|yen banknote|日幣 貨幣 鈔票 錢
Objects|💵|0.6|dollar banknote|美金 貨幣 鈔票 錢
Objects|💶|1.0|euro banknote|一百歐元 歐元 貨幣 鈔票 錢
Objects|💷|1.0|pound banknote|英鎊 貨幣 鈔票 錢
Objects|💸|0.6|money with wings|沒錢了 錢跑了 錢飛了
Objects|💳|0.6|credit card|信用卡 刷卡
Objects|🧾|11.0|receipt|收執聯 收據 會計 發票 簿記 紙本 記帳 證據 證明
Objects|💹|0.6|chart increasing with yen|上揚 圖表 市場走向 貨幣升值
Objects|✉️|0.6|envelope|信 信封 郵件
Objects|📧|0.6|e-mail|email 郵件 電子郵件
Objects|📨|0.6|incoming envelope|信件 信封 接收 收到郵件 送信 郵件
Objects|📩|0.6|envelope with arrow|信件 信封 寄出郵件 發送 郵件 電子郵件
Objects|📤|0.6|outbox tray|寄件匣 發信匣
Objects|📥|0.6|inbox tray|收件匣 收信匣
Objects|📦|0.6|package|包裹 寄包裹 紙箱
Objects|📫|0.6|closed mailbox with raised flag|信箱 有待收郵件 郵箱
Objects|📪|0.6|closed mailbox with lowered flag|信箱 無待收郵件 郵箱
Objects|📬|0.7|open mailbox with raised flag|信箱 有新郵件 郵箱
Objects|📭|0.7|open mailbox with lowered flag|信箱 沒有新郵件 郵箱
Objects|📮|0.6|postbox|信箱 郵件 郵箱
Objects|🗳️|0.7|ballot box with ballot|投票箱 票箱
Objects|✏️|0.6|pencil|鉛筆
Objects|✒️|0.6|black nib|筆尖 鋼筆 鋼筆頭
Objects|🖋️|0.7|fountain pen|鋼筆
Objects|🖊️|0.7|pen|原子筆 筆
Objects|🖌️|0.7|paintbrush|漆刷 畫筆
Objects|🖍️|0.7|crayon|蠟筆
Objects|📝|0.6|memo|備忘錄 備註 媒體 鉛筆
Objects|🪌|18.0|eraser|
Objects|💼|0.6|briefcase|公事包 辦公室
Objects|📁|0.6|file folder|文件夾 檔案 資料夾
Objects|📂|0.6|open file folder|打開檔案 打開資料夾 檔案 資料夾
Objects|🗂️|0.7|card index dividers|分隔文件夹 索引卡 索引板 索引隔板
Objects|📅|0.6|calendar|日期 行事曆
Objects|📆|0.6|tear-off calendar|撕日曆 日曆 行事曆
Objects|🗒️|0.7|spiral notepad|筆記本 線圈筆記本
Objects|🗓️|0.7|spiral calendar|日曆 線圈日曆
Objects|📇|0.6|card index|名片索引 索引卡
Objects|📈|0.6|chart increasing|上升 上漲 圖表 漲
Objects|📉|0.6|chart decreasing|下跌 下降 圖表 跌 跌勢
Objects|📊|0.6|bar chart|圖表 橫條圖 直方圖
Objects|📋|0.6|clipboard|代辦事項 寫字夾板 筆記
Objects|📌|0.6|pushpin|圖釘 大頭釘
Objects|📍|0.6|round pushpin|圓圖釘 圓頭大頭針 圖釘 大頭針
Objects|📎|0.6|paperclip|迴紋針
Objects|🖇️|0.7|linked paperclips|回紋針 相連 相連的回紋針
Objects|📏|0.6|straight ruler|尺 直尺
Objects|📐|0.6|triangular ruler|三角尺 尺
Objects|✂️|0.6|scissors|剪 剪刀 剪切 工具
Objects|🗃️|0.7|card file box|卡片 卡片目錄盒 目錄盒
Objects|🗄️|0.7|file cabinet|檔案櫃 歸檔
Objects|🗑️|0.7|wastebasket|字紙簍 廢紙簍
Objects|🔒|0.6|locked|上鎖 私人的 鎖
Objects|🔓|0.6|unlocked|開鎖
Objects|🔏|0.6|locked with pen|以筆上鎖 鋼筆 鋼筆和鎖 鎖 隱私
Objects|🔐|0.6|locked with key|腳踏車鎖 鎖 鎖起來 鑰匙 鑰匙和鎖
Objects|🔑|0.6|key|密碼 解鎖 鎖 鑰匙
Objects|🗝️|0.7|old key|老鑰匙 鑰匙
Objects|🪍|18.0|net with handle|
Objects|🔨|0.6|hammer|榔頭 鎚子
Objects|🪓|12.0|axe|分割 手斧 斧頭 木頭 短斧 砍
Objects|⛏️|0.7|pick|十字鎬 鑿
Objects|⚒️|1.0|hammer and pick|十字鎬 鎚子 鎚子和十字鎬
Objects|🛠️|0.7|hammer and wrench|扳手 榔頭和扳手 鎚子 鎚子和扳手
Objects|🗡️|0.7|dagger|刀 匕首
Objects|⚔️|1.0|crossed swords|劍
Objects|💣|0.6|bomb|危險 地雷 炸彈 爆炸 雷區
Objects|🪃|13.0|boomerang|原住民的 回飛棒 武器 澳洲 迴力鏢 迴旋 迴旋鏢
Objects|🏹|1.0|bow and arrow|射手 射手座 射箭 弓箭
Objects|🛡️|0.7|shield|盾牌
Objects|🪚|13.0|carpentry saw|切 工具 木工 木工鋸 木材 鋸子
Objects|🔧|0.6|wrench|扳手
Objects|🪛|13.0|screwdriver|一字起子 工具 羅賴把 螺絲 螺絲起子
Objects|🔩|0.6|nut and bolt|螺栓 螺絲 螺絲與螺帽
Objects|⚙️|1.0|gear|齒輪
Objects|🗜️|0.7|clamp|壓縮 壓縮機 夾具 鉗子
Objects|⚖️|1.0|balance scale|司法 天平 天枰座
Objects|🦯|12.0|white cane|導盲手杖 盲人 行動不便
Objects|🔗|0.6|link|連接 連結 鏈結
Objects|⛓️‍💥|15.1|broken chain|斷掉、斷開、鏈條、手銬、自由 斷掉的鏈條
Objects|⛓️|0.7|chains|鍊子 鍊條
Objects|🪝|13.0|hook|勾 彎曲 鉤 鉤子 鉤形
Objects|🧰|11.0|toolbox|器具 工具 工具箱 機械工 箱子 紅盒子
Objects|🧲|11.0|magnet|U 型 五金 吸引 正負 磁力 磁吸 磁鐵 馬蹄
Objects|🪜|13.0|ladder|梯凳 梯子 橫木 爬 踩 階梯
Objects|🪏|16.0|shovel|挖 洞 鏟 鏟子
Objects|⚗️|1.0|alembic|化學 蒸餾 蒸餾器
Objects|🧪|11.0|test tube|化學 化學家 實驗 實驗室 科學 試管
Objects|🧫|11.0|petri dish|培養 培養皿 基因 實驗 實驗室 生物 生物學家 細菌
Objects|🧬|11.0|dna|DNA 基因 演化 生命 生物 生物學家
Objects|🔬|1.0|microscope|實驗 實驗室 顯微鏡
Objects|🔭|1.0|telescope|望遠鏡 觀測
Objects|📡|0.6|satellite antenna|外星人 天線 衛星天線
Objects|💉|0.6|syringe|注射器 針筒
Objects|🩸|12.0|drop of blood|受傷 捐血 流血 生理期 藥 血滴
Objects|💊|0.6|pill|生病 維他命 藥 藥丸
Objects|🩹|12.0|adhesive bandage|OK 繃 繃帶
Objects|🩼|14.0|crutch|助行 受傷 手杖 拐杖 行動不便 輔助
Objects|🩺|12.0|stethoscope|心跳 聽診器 藥 醫生
Objects|🩻|14.0|x-ray|X 光 醫學 醫生 骨頭 骨骼 骷髏
Objects|🚪|0.6|door|前門 後門 櫃子 門
Objects|🛗|13.0|elevator|上升 方便 貨梯 電梯
Objects|🪞|13.0|mirror|化妝 化妝鏡 反射 反射鏡 反映 鏡子
Objects|🪟|13.0|window|框 窗 窗戶 觀景 透明
Objects|🛏️|0.7|bed|床 睡覺
Objects|🛋️|0.7|couch and lamp|沙發 沙發和立燈 立燈
Objects|🪑|12.0|chair|坐 座椅 椅子
Objects|🚽|0.6|toilet|廁所 馬桶
Objects|🪠|13.0|plunger|吸把 大便 廁所 通水器 通馬桶
Objects|🚿|1.0|shower|淋浴 蓮蓬頭
Objects|🛁|1.0|bathtub|浴盆 浴缸 澡盆
Objects|🪤|13.0|mouse trap|捕鼠 捕鼠器 捕鼠夾 誘捕 起司 陷阱 餌
Objects|🪒|12.0|razor|剃 剃刀 鋒利
Objects|🧴|11.0|lotion bottle|乳液 乳液瓶 保濕 保濕乳液 洗髮精 防曬 防曬乳
Objects|🧷|11.0|safety pin|安全別針 尿布 龐克搖滾
Objects|🧹|11.0|broom|巫婆 掃 掃地 掃帚 掃把 清潔 清理
Objects|🧺|11.0|basket|洗衣 種植 籃子 農作 野餐
Objects|🧻|11.0|roll of paper|捲筒衛生紙 紙巾 紙捲 衛生紙
Objects|🪣|13.0|bucket|一桶 提桶 桶 桶子 水桶
Objects|🧼|11.0|soap|泡沫 洗澡 清潔 肥皂 肥皂盒 肥皂盤
Objects|🫧|14.0|bubbles|打嗝 水中 泡泡 清潔 漂浮 珍珠 肥皂
Objects|🪥|13.0|toothbrush|乾淨 刷子 浴室 清潔 牙刷 牙齒 衛浴用品
Objects|🧽|11.0|sponge|吸收 吸水 多孔 海綿 浸泡 清潔 透氣
Objects|🧯|11.0|fire extinguisher|撲滅 滅火 滅火器
Objects|🛒|3.0|shopping cart|推車 購物 購物車
Objects|🚬|0.6|cigarette|吸煙 抽煙 香菸 點煙
Objects|⚰️|1.0|coffin|棺木 棺材
Objects|🪦|13.0|headstone|RIP 墓 墓園 墓石 墓碑 墳墓 安息 死 死亡 紀念
Objects|⚱️|1.0|funeral urn|骨灰甕 骨灰罈
Objects|🧿|11.0|nazar amulet|珠子 符咒 藍眼 藍色 護身符 避邪 邪眼
Objects|🪬|14.0|hamsa|保護 幸運 手 指引 法蒂瑪 法蒂瑪之手 瑪麗 米利暗 護身符 避邪物
Objects|🗿|0.6|moai|復活島石像 復活節島
Objects|🪧|13.0|placard|佈告 公告 告示 告示牌 標示 標語 標語牌
Objects|🪪|14.0|identification card|ID 執照 安全 憑證 授權 證件 證照 識別證 身分證 身分證明
Symbols|🏧|0.6|ATM sign|提款機
Symbols|🚮|1.0|litter in bin sign|垃圾桶
Symbols|🚰|1.0|potable water|可飲 飲用水
Symbols|♿|0.6|wheelchair symbol|無障礙空間 行動不便者 身障人士 輪椅
Symbols|🚹|0.6|men’s room|男廁
Symbols|🚺|0.6|women’s room|女廁
Symbols|🚻|0.6|restroom|廁所 洗手間
Symbols|🚼|0.6|baby symbol|嬰兒 寶寶
Symbols|🚾|0.6|water closet|廁所 盥洗室
Symbols|🛂|1.0|passport control|入出境關卡 護照 護照查驗
Symbols|🛃|1.0|customs|打包 海關
Symbols|🛄|1.0|baggage claim|提取行李 行李
Symbols|🛅|1.0|left luggage|寄存行李 寄物 寄物櫃
Symbols|⚠️|0.6|warning|警告
Symbols|🚸|1.0|children crossing|小心兒童 當心兒童 行人優先
Symbols|⛔|0.6|no entry|禁止通行 禁止進入 禁行
Symbols|🚫|0.6|prohibited|禁止 禁止通行 禁止進入
Symbols|🚳|1.0|no bicycles|禁止通行 禁行自行車
Symbols|🚭|0.6|no smoking|禁止吸煙 禁煙
Symbols|🚯|1.0|no littering|禁止亂丟垃圾 請勿亂丟垃圾
Symbols|🚱|1.0|non-potable water|不得生飲 非飲用水
Symbols|🚷|1.0|no pedestrians|禁止行人通行 禁止通行
Symbols|📵|1.0|no mobile phones|禁用手機
Symbols|🔞|0.6|no one under eighteen|18 禁 未成年人不宜
Symbols|☢️|1.0|radioactive|放射性 標誌 輻射
Symbols|☣️|1.0|biohazard|危害生物 對生物有害
Symbols|⬆️|0.6|up arrow|北方 向上箭頭 方向
Symbols|↗️|0.6|up-right arrow|右上箭頭 方向 東北
Symbols|➡️|0.6|right arrow|向右箭頭 方向 東
Symbols|↘️|0.6|down-right arrow|右下箭頭 方向 東南
Symbols|⬇️|0.6|down arrow|南方 向下箭頭 方向
Symbols|↙️|0.6|down-left arrow|左下箭頭 方向 西南
Symbols|⬅️|0.6|left arrow|向左箭頭 方向 西方
Symbols|↖️|0.6|up-left arrow|左上箭頭 方向 西北
Symbols|↕️|0.6|up-down arrow|上下箭頭
Symbols|↔️|0.6|left-right arrow|左右箭頭
Symbols|↩️|0.6|right arrow curving left|右轉箭頭 向左彎的右箭頭
Symbols|↪️|0.6|left arrow curving right|向右彎的左箭頭 左轉箭頭
Symbols|⤴️|0.6|right arrow curving up|右上旋轉箭頭
Symbols|⤵️|0.6|right arrow curving down|右下旋轉箭頭
Symbols|🔃|0.6|clockwise vertical arrows|刷新 重新載入 順時針 順時針方向
Symbols|🔄|1.0|counterclockwise arrows button|倒帶 再一次 剪頭 逆時針
Symbols|🔙|0.6|BACK arrow|返回
Symbols|🔚|0.6|END arrow|結束
Symbols|🔛|0.6|ON! arrow|ON
Symbols|🔜|0.6|SOON arrow|OMW On my way! 在路上 馬上
Symbols|🔝|0.6|TOP arrow|箭頭向上 置頂
Symbols|🛐|1.0|place of worship|祈禱 祝禱
Symbols|⚛️|1.0|atom symbol|原子 無神論者
Symbols|🕉️|0.7|om|印度教 唵 梵文
Symbols|✡️|0.7|star of David|六芒星 六角星 大衛之星 猶太教
Symbols|☸️|0.7|wheel of dharma|法輪
Symbols|☯️|0.7|yin yang|陰陽
Symbols|✝️|0.7|latin cross|十字架 基督教 拉丁十字架
Symbols|☦️|1.0|orthodox cross|十字架 東正教十字架 正教會十字
Symbols|☪️|0.7|star and crescent|伊斯蘭教 伊斯蘭教星月 星月 齋戒月
Symbols|☮️|1.0|peace symbol|和平
Symbols|🕎|1.0|menorah|猶太燭台
Symbols|🔯|0.6|dotted six-pointed star|六芒星加圓點 六角星 猶太教
Symbols|🪯|15.0|khanda|印度直劍，印度劍，法器，錫克教，錫克，善業與佩劍得勝，信仰，宗教 堪達 宗教 錫克教
Symbols|♈|0.6|Aries|星座 牡羊座
Symbols|♉|0.6|Taurus|星座 金牛座
Symbols|♊|0.6|Gemini|星座 雙子座
Symbols|♋|0.6|Cancer|巨蟹座 星座
Symbols|♌|0.6|Leo|星座 獅子座
Symbols|♍|0.6|Virgo|星座 處女座
Symbols|♎|0.6|Libra|天秤座 星座
Symbols|♏|0.6|Scorpio|天蠍座 星座
Symbols|♐|0.6|Sagittarius|射手座 星座
Symbols|♑|0.6|Capricorn|摩羯座 星座
Symbols|♒|0.6|Aquarius|星座 水瓶座
Symbols|♓|0.6|Pisces|星座 雙魚座
Symbols|⛎|0.6|Ophiuchus|星座 蛇夫宮 蛇夫座
Symbols|🔀|1.0|shuffle tracks button|交叉 隨機播放
Symbols|🔁|1.0|repeat button|重複 重複播放 順時針
Symbols|🔂|1.0|repeat single button|一次 重複目前單曲 順時針方向
Symbols|▶️|0.6|play button|右 按鈕 播放
Symbols|⏩|0.6|fast-forward button|向前快轉 按鈕
Symbols|⏭️|0.7|next track button|下一幕 下一首 按鈕
Symbols|⏯️|1.0|play or pause button|按鈕 播放或暫停 暫停
Symbols|◀️|0.6|reverse button|倒轉 左 按鈕
Symbols|⏪|0.6|fast reverse button|向後快轉 按鈕
Symbols|⏮️|0.7|last track button|上一首 最後一首 前一幕
Symbols|🔼|0.6|upwards button|向上 按鈕 紅
Symbols|⏫|0.6|fast up button|向上箭頭 快速向上
Symbols|🔽|0.6|downwards button|向下 按鈕 紅
Symbols|⏬|0.6|fast down button|向下箭頭 快速向下
Symbols|⏸️|0.7|pause button|按鈕 暫停 暫停鈕
Symbols|⏹️|0.7|stop button|停止 停止播放 按鈕 方塊
Symbols|⏺️|0.7|record button|圓 按鈕 錄製
Symbols|⏏️|1.0|eject button|按鈕 退出
Symbols|🎦|0.6|cinema|戲院 攝影機 電影 電影院
Symbols|🔅|1.0|dim button|低亮度 微亮
Symbols|🔆|1.0|bright button|明亮 高亮度
Symbols|📶|0.6|antenna bars|信號 訊號強弱 訊號格數
Symbols|🛜|15.0|wireless|無線 無線網路，wifi，路由器，連線，熱點，寬頻，網路，智慧型手機，電腦 網路 網際網路 電腦
Symbols|📳|0.6|vibration mode|震動 震動模式
Symbols|📴|0.6|mobile phone off|手機關機 關閉
Symbols|♀️|4.0|female sign|女
Symbols|♂️|4.0|male sign|男
Symbols|⚧️|13.0|transgender symbol|變性 變性符號
Symbols|✖️|0.6|multiply|× x 乘 乘法 乘法號 乘號 叉 取消 打叉 符號
Symbols|➕|0.6|plus|+ 加 加號 數學 符號
Symbols|➖|0.6|minus|- − 數學 減 減號 符號 負
Symbols|➗|0.6|divide|÷ 數學 符號 除 除法 除號
Symbols|🟰|14.0|heavy equals sign|數學 相等 相等於 等式 等於 答案 粗體等號
Symbols|♾️|11.0|infinity|全體 永遠 無限 無限大
Symbols|‼️|0.6|double exclamation mark|標點 雙驚嘆號
Symbols|⁉️|0.6|exclamation question mark|標點 驚嘆號加問號
Symbols|❓|0.6|red question mark|問號 標點 紅色問號
Symbols|❔|0.6|white question mark|問號 標點 白色問號
Symbols|❕|0.6|white exclamation mark|標點 白色驚嘆號 驚嘆號
Symbols|❗|0.6|red exclamation mark|標點 紅色驚嘆號 驚嘆號
Symbols|〰️|0.6|wavy dash|標點 波浪形 波浪線
Symbols|💱|0.6|currency exchange|換匯 貨幣兌換
Symbols|💲|0.6|heavy dollar sign|貨幣 貨幣符號 錢
Symbols|⚕️|4.0|medical symbol|醫學 醫療 醫療符號 醫藥
Symbols|♻️|0.6|recycling symbol|可回收資源 回收
Symbols|⚜️|1.0|fleur-de-lis|百合花 鳶尾花
Symbols|🔱|0.6|trident emblem|三叉戟 錨
Symbols|📛|0.6|name badge|名牌 胸牌
Symbols|🔰|0.6|Japanese symbol for beginner|V 型臂章 新手 日本初學者 日本初學者符號
Symbols|⭕|0.6|hollow red circle|丸 圓 圓圈
Symbols|✅|0.6|check mark button|勾號 完成 打勾 搞定 白色勾勾
Symbols|☑️|0.6|check box with check|勾號 勾選 打勾
Symbols|✔️|0.6|check mark|勾號 打勾
Symbols|❌|0.6|cross mark|乘 叉
Symbols|❎|0.6|cross mark button|乘 叉 叉叉
Symbols|➰|0.6|curly loop|單環 日本單環標誌
Symbols|➿|1.0|double curly loop|免費電話 日本免費電話標誌
Symbols|〽️|0.6|part alternation mark|歌唱 歌記號
Symbols|✳️|0.6|eight-spoked asterisk|八芒星 星號
Symbols|✴️|0.6|eight-pointed star|八角星
Symbols|❇️|0.6|sparkle|火花 閃亮
Symbols|©️|0.6|copyright|版權
Symbols|®️|0.6|registered|註冊
Symbols|™️|0.6|trade mark|商標
Symbols|🫟|16.0|splatter|侯麗節 噴濺 弄髒 顏料 飛濺 潑濺
Symbols|#️⃣|0.6|keycap: #|
Symbols|*️⃣|2.0|keycap: *|
Symbols|0️⃣|0.6|keycap: 0|0 按鍵 按鍵：0
Symbols|1️⃣|0.6|keycap: 1|1 一 按鍵 按鍵：1
Symbols|2️⃣|0.6|keycap: 2|2 二 按鍵 按鍵：2
Symbols|3️⃣|0.6|keycap: 3|3 三 按鍵 按鍵：3
Symbols|4️⃣|0.6|keycap: 4|4 四 按鍵 按鍵：4
Symbols|5️⃣|0.6|keycap: 5|5 五 按鍵 按鍵：5
Symbols|6️⃣|0.6|keycap: 6|6 六 按鍵 按鍵：6
Symbols|7️⃣|0.6|keycap: 7|7 七 按鍵 按鍵：7
Symbols|8️⃣|0.6|keycap: 8|8 八 按鍵 按鍵：8
Symbols|9️⃣|0.6|keycap: 9|9 九 按鍵 按鍵：9
Symbols|🔟|0.6|keycap: 10|
Symbols|🔠|0.6|input latin uppercase|ABCD 大寫 大寫字母鍵 字母 輸入
Symbols|🔡|0.6|input latin lowercase|abcd 字母 小寫 小寫字母鍵 輸入
Symbols|🔢|0.6|input numbers|123 數字 數字鍵 輸入
Symbols|🔣|0.6|input symbols|符號鍵 輸入 輸入符號
Symbols|🔤|0.6|input latin letters|abc 拉丁字母鍵
Symbols|🅰️|0.6|A button (blood type)|A型 血型
Symbols|🆎|0.6|AB button (blood type)|AB型 血型
Symbols|🅱️|0.6|B button (blood type)|B型 血型
Symbols|🆑|0.6|CL button|CL
Symbols|🆒|0.6|COOL button|酷
Symbols|🆓|0.6|FREE button|免費
Symbols|ℹ️|0.6|information|詢問處 資訊
Symbols|🆔|0.6|ID button|ID 身份 身分
Symbols|Ⓜ️|0.6|circled M|M
Symbols|🆕|0.6|NEW button|新
Symbols|🆖|0.6|NG button|NG 重來
Symbols|🅾️|0.6|O button (blood type)|O型 血型
Symbols|🆗|0.6|OK button|ok OK 可以 好的 沒問題
Symbols|🅿️|0.6|P button|p P 停車
Symbols|🆘|0.6|SOS button|救命 求救
Symbols|🆙|0.6|UP! button|up UP 向上
Symbols|🆚|0.6|VS button|vs 對戰 比
Symbols|🈁|0.6|Japanese “here” button|koko 日文KOKO 日語 片假名 這裡
Symbols|🈂️|0.6|Japanese “service charge” button|sa 日文服務區 日語 服務費 片假名
Symbols|🈷️|0.6|Japanese “monthly amount” button|月 月金额
Symbols|🈶|0.6|Japanese “not free of charge” button|有 需付費 非免費
Symbols|🈯|0.6|Japanese “reserved” button|指 預約保留
Symbols|🉐|0.6|Japanese “bargain” button|俗 得
Symbols|🈹|0.6|Japanese “discount” button|割
Symbols|🈚|0.6|Japanese “free of charge” button|免費 無
Symbols|🈲|0.6|Japanese “prohibited” button|禁 禁止
Symbols|🉑|0.6|Japanese “acceptable” button|OK 可
Symbols|🈸|0.6|Japanese “application” button|申 申請
Symbols|🈴|0.6|Japanese “passing grade” button|合 過 過關
Symbols|🈳|0.6|Japanese “vacancy” button|空 空的
Symbols|㊗️|0.6|Japanese “congratulations” button|祝
Symbols|㊙️|0.6|Japanese “secret” button|秘 秘密
Symbols|🈺|0.6|Japanese “open for business” button|營 營業中
Symbols|🈵|0.6|Japanese “no vacancy” button|滿
Symbols|🔴|0.6|red circle|圓形 大紅色圓形 紅丸
Symbols|🟠|12.0|orange circle|圓形 橘色 橘色圓形
Symbols|🟡|12.0|yellow circle|圓形 黃色 黃色圓形
Symbols|🟢|12.0|green circle|圓形 綠色 綠色圓形
Symbols|🔵|0.6|blue circle|圓形 大藍色圓形 藍丸
Symbols|🟣|12.0|purple circle|圓形 紫色 紫色圓形
Symbols|🟤|12.0|brown circle|咖啡色 咖啡色方形 圓形 褐色 褐色圓形
Symbols|⚫|0.6|black circle|圓形 黑丸 黑色圓形
Symbols|⚪|0.6|white circle|圓形 白丸 白色圓形
Symbols|🟥|12.0|red square|方形 紅色 紅色方形
Symbols|🟧|12.0|orange square|方形 橘色 橘色方形
Symbols|🟨|12.0|yellow square|方形 黃色 黃色方形
Symbols|🟩|12.0|green square|方形 綠色 綠色方形
Symbols|🟦|12.0|blue square|方形 藍色 藍色方形
Symbols|🟪|12.0|purple square|方形 紫色 紫色方形
Symbols|🟫|12.0|brown square|咖啡色 咖啡色方形 方形 褐色 褐色方形
Symbols|⬛|0.6|black large square|方形 黑色大方塊
Symbols|⬜|0.6|white large square|方形 白色大方塊
Symbols|◼️|0.6|black medium square|方形 黑色中方塊
Symbols|◻️|0.6|white medium square|方形 白色中方塊 白色方塊
Symbols|◾|0.6|black medium-small square|方形 黑方塊 黑色中小型方塊
Symbols|◽|0.6|white medium-small square|方塊 方形 白色中小型方塊 白色小方塊
Symbols|▪️|0.6|black small square|方形 黑色小方塊 黑色方塊
Symbols|▫️|0.6|white small square|方形 白色小方塊
Symbols|🔶|0.6|large orange diamond|大橘色鑽石 大橙色菱形 菱形
Symbols|🔷|0.6|large blue diamond|大藍色菱形 大藍色鑽石 菱形
Symbols|🔸|0.6|small orange diamond|小橘色鑽石 小橙色菱形 菱形
Symbols|🔹|0.6|small blue diamond|小藍色菱形 菱形
Symbols|🔺|0.6|red triangle pointed up|三角形 向上紅色三角
Symbols|🔻|0.6|red triangle pointed down|三角形 向下紅色三角
Symbols|💠|0.6|diamond with a dot|菱形加圓點 鑽石
Symbols|🔘|0.6|radio button|圓鈕 幾何 按鈕
Symbols|🔳|0.6|white square button|按鈕 白色按鈕 白色方按鈕
Symbols|🔲|0.6|black square button|按鈕 方形 方形按鈕 黑色方按鈕
Flags|🏁|0.6|chequered flag|格子旗 終點旗 賽車
Flags|🚩|0.6|triangular flag|三角旗
Flags|🎌|0.6|crossed flags|半程 旗 日本 盟友 紀念日
Flags|🏴|1.0|black flag|揮黑旗 黑旗
Flags|🏳️|0.7|white flag|搖白旗 白旗 豎白旗
Flags|🏳️‍🌈|4.0|rainbow flag|LGBT 同志 彩虹旗 跨性別 雙性
Flags|🏳️‍⚧️|13.0|transgender flag|旗子 變性 跨性別旗
Flags|🏴‍☠️|11.0|pirate flag|寶藏 掠奪 海盜 海盜旗 骷髏旗
Flags|🇦🇨|2.0|flag: Ascension Island|
Flags|🇦🇩|2.0|flag: Andorra|
Flags|🇦🇪|2.0|flag: United Arab Emirates|
Flags|🇦🇫|2.0|flag: Afghanistan|
Flags|🇦🇬|2.0|flag: Antigua & Barbuda|
Flags|🇦🇮|2.0|flag: Anguilla|
Flags|🇦🇱|2.0|flag: Albania|
Flags|🇦🇲|2.0|flag: Armenia|
Flags|🇦🇴|2.0|flag: Angola|
Flags|🇦🇶|2.0|flag: Antarctica|
Flags|🇦🇷|2.0|flag: Argentina|
Flags|🇦🇸|2.0|flag: American Samoa|
Flags|🇦🇹|2.0|flag: Austria|
Flags|🇦🇺|2.0|flag: Australia|
Flags|🇦🇼|2.0|flag: Aruba|
Flags|🇦🇽|2.0|flag: Åland Islands|
Flags|🇦🇿|2.0|flag: Azerbaijan|
Flags|🇧🇦|2.0|flag: Bosnia & Herzegovina|
Flags|🇧🇧|2.0|flag: Barbados|
Flags|🇧🇩|2.0|flag: Bangladesh|
Flags|🇧🇪|2.0|flag: Belgium|
Flags|🇧🇫|2.0|flag: Burkina Faso|
Flags|🇧🇬|2.0|flag: Bulgaria|
Flags|🇧🇭|2.0|flag: Bahrain|
Flags|🇧🇮|2.0|flag: Burundi|
Flags|🇧🇯|2.0|flag: Benin|
Flags|🇧🇱|2.0|flag: St. Barthélemy|
Flags|🇧🇲|2.0|flag: Bermuda|
Flags|🇧🇳|2.0|flag: Brunei|
Flags|🇧🇴|2.0|flag: Bolivia|
Flags|🇧🇶|2.0|flag: Caribbean Netherlands|
Flags|🇧🇷|2.0|flag: Brazil|
Flags|🇧🇸|2.0|flag: Bahamas|
Flags|🇧🇹|2.0|flag: Bhutan|
Flags|🇧🇻|2.0|flag: Bouvet Island|
Flags|🇧🇼|2.0|flag: Botswana|
Flags|🇧🇾|2.0|flag: Belarus|
Flags|🇧🇿|2.0|flag: Belize|
Flags|🇨🇦|2.0|flag: Canada|
Flags|🇨🇨|2.0|flag: Cocos (Keeling) Islands|
Flags|🇨🇩|2.0|flag: Congo - Kinshasa|
Flags|🇨🇫|2.0|flag: Central African Republic|
Flags|🇨🇬|2.0|flag: Congo - Brazzaville|
Flags|🇨🇭|2.0|flag: Switzerland|
Flags|🇨🇮|2.0|flag: Côte d’Ivoire|
Flags|🇨🇰|2.0|flag: Cook Islands|
Flags|🇨🇱|2.0|flag: Chile|
Flags|🇨🇲|2.0|flag: Cameroon|
Flags|🇨🇳|0.6|flag: China|
Flags|🇨🇴|2.0|flag: Colombia|
Flags|🇨🇵|2.0|flag: Clipperton Island|
Flags|🇨🇶|16.0|flag: Sark|
Flags|🇨🇷|2.0|flag: Costa Rica|
Flags|🇨🇺|2.0|flag: Cuba|
Flags|🇨🇻|2.0|flag: Cape Verde|
Flags|🇨🇼|2.0|flag: Curaçao|
Flags|🇨🇽|2.0|flag: Christmas Island|
Flags|🇨🇾|2.0|flag: Cyprus|
Flags|🇨🇿|2.0|flag: Czechia|
Flags|🇩🇪|0.6|flag: Germany|
Flags|🇩🇬|2.0|flag: Diego Garcia|
Flags|🇩🇯|2.0|flag: Djibouti|
Flags|🇩🇰|2.0|flag: Denmark|
Flags|🇩🇲|2.0|flag: Dominica|
Flags|🇩🇴|2.0|flag: Dominican Republic|
Flags|🇩🇿|2.0|flag: Algeria|
Flags|🇪🇦|2.0|flag: Ceuta & Melilla|
Flags|🇪🇨|2.0|flag: Ecuador|
Flags|🇪🇪|2.0|flag: Estonia|
Flags|🇪🇬|2.0|flag: Egypt|
Flags|🇪🇭|2.0|flag: Western Sahara|
Flags|🇪🇷|2.0|flag: Eritrea|
Flags|🇪🇸|0.6|flag: Spain|
Flags|🇪🇹|2.0|flag: Ethiopia|
Flags|🇪🇺|2.0|flag: European Union|
Flags|🇫🇮|2.0|flag: Finland|
Flags|🇫🇯|2.0|flag: Fiji|
Flags|🇫🇰|2.0|flag: Falkland Islands|
Flags|🇫🇲|2.0|flag: Micronesia|
Flags|🇫🇴|2.0|flag: Faroe Islands|
Flags|🇫🇷|0.6|flag: France|
Flags|🇬🇦|2.0|flag: Gabon|
Flags|🇬🇧|0.6|flag: United Kingdom|
Flags|🇬🇩|2.0|flag: Grenada|
Flags|🇬🇪|2.0|flag: Georgia|
Flags|🇬🇫|2.0|flag: French Guiana|
Flags|🇬🇬|2.0|flag: Guernsey|
Flags|🇬🇭|2.0|flag: Ghana|
Flags|🇬🇮|2.0|flag: Gibraltar|
Flags|🇬🇱|2.0|flag: Greenland|
Flags|🇬🇲|2.0|flag: Gambia|
Flags|🇬🇳|2.0|flag: Guinea|
Flags|🇬🇵|2.0|flag: Guadeloupe|
Flags|🇬🇶|2.0|flag: Equatorial Guinea|
Flags|🇬🇷|2.0|flag: Greece|
Flags|🇬🇸|2.0|flag: South Georgia & South Sandwich Islands|
Flags|🇬🇹|2.0|flag: Guatemala|
Flags|🇬🇺|2.0|flag: Guam|
Flags|🇬🇼|2.0|flag: Guinea-Bissau|
Flags|🇬🇾|2.0|flag: Guyana|
Flags|🇭🇰|2.0|flag: Hong Kong SAR China|
Flags|🇭🇲|2.0|flag: Heard Island & McDonald Islands|
Flags|🇭🇳|2.0|flag: Honduras|
Flags|🇭🇷|2.0|flag: Croatia|
Flags|🇭🇹|2.0|flag: Haiti|
Flags|🇭🇺|2.0|flag: Hungary|
Flags|🇮🇨|2.0|flag: Canary Islands|
Flags|🇮🇩|2.0|flag: Indonesia|
Flags|🇮🇪|2.0|flag: Ireland|
Flags|🇮🇱|2.0|flag: Israel|
Flags|🇮🇲|2.0|flag: Isle of Man|
Flags|🇮🇳|2.0|flag: India|
Flags|🇮🇴|2.0|flag: British Indian Ocean Territory|
Flags|🇮🇶|2.0|flag: Iraq|
Flags|🇮🇷|2.0|flag: Iran|
Flags|🇮🇸|2.0|flag: Iceland|
Flags|🇮🇹|0.6|flag: Italy|
Flags|🇯🇪|2.0|flag: Jersey|
Flags|🇯🇲|2.0|flag: Jamaica|
Flags|🇯🇴|2.0|flag: Jordan|
Flags|🇯🇵|0.6|flag: Japan|
Flags|🇰🇪|2.0|flag: Kenya|
Flags|🇰🇬|2.0|flag: Kyrgyzstan|
Flags|🇰🇭|2.0|flag: Cambodia|
Flags|🇰🇮|2.0|flag: Kiribati|
Flags|🇰🇲|2.0|flag: Comoros|
Flags|🇰🇳|2.0|flag: St. Kitts & Nevis|
Flags|🇰🇵|2.0|flag: North Korea|
Flags|🇰🇷|0.6|flag: South Korea|
Flags|🇰🇼|2.0|flag: Kuwait|
Flags|🇰🇾|2.0|flag: Cayman Islands|
Flags|🇰🇿|2.0|flag: Kazakhstan|
Flags|🇱🇦|2.0|flag: Laos|
Flags|🇱🇧|2.0|flag: Lebanon|
Flags|🇱🇨|2.0|flag: St. Lucia|
Flags|🇱🇮|2.0|flag: Liechtenstein|
Flags|🇱🇰|2.0|flag: Sri Lanka|
Flags|🇱🇷|2.0|flag: Liberia|
Flags|🇱🇸|2.0|flag: Lesotho|
Flags|🇱🇹|2.0|flag: Lithuania|
Flags|🇱🇺|2.0|flag: Luxembourg|
Flags|🇱🇻|2.0|flag: Latvia|
Flags|🇱🇾|2.0|flag: Libya|
Flags|🇲🇦|2.0|flag: Morocco|
Flags|🇲🇨|2.0|flag: Monaco|
Flags|🇲🇩|2.0|flag: Moldova|
Flags|🇲🇪|2.0|flag: Montenegro|
Flags|🇲🇫|2.0|flag: St. Martin|
Flags|🇲🇬|2.0|flag: Madagascar|
Flags|🇲🇭|2.0|flag: Marshall Islands|
Flags|🇲🇰|2.0|flag: North Macedonia|
Flags|🇲🇱|2.0|flag: Mali|
Flags|🇲🇲|2.0|flag: Myanmar (Burma)|
Flags|🇲🇳|2.0|flag: Mongolia|
Flags|🇲🇴|2.0|flag: Macao SAR China|
Flags|🇲🇵|2.0|flag: Northern Mariana Islands|
Flags|🇲🇶|2.0|flag: Martinique|
Flags|🇲🇷|2.0|flag: Mauritania|
Flags|🇲🇸|2.0|flag: Montserrat|
Flags|🇲🇹|2.0|flag: Malta|
Flags|🇲🇺|2.0|flag: Mauritius|
Flags|🇲🇻|2.0|flag: Maldives|
Flags|🇲🇼|2.0|flag: Malawi|
Flags|🇲🇽|2.0|flag: Mexico|
Flags|🇲🇾|2.0|flag: Malaysia|
Flags|🇲🇿|2.0|flag: Mozambique|
Flags|🇳🇦|2.0|flag: Namibia|
Flags|🇳🇨|2.0|flag: New Caledonia|
Flags|🇳🇪|2.0|flag: Niger|
Flags|🇳🇫|2.0|flag: Norfolk Island|
Flags|🇳🇬|2.0|flag: Nigeria|
Flags|🇳🇮|2.0|flag: Nicaragua|
Flags|🇳🇱|2.0|flag: Netherlands|
Flags|🇳🇴|2.0|flag: Norway|
Flags|🇳🇵|2.0|flag: Nepal|
Flags|🇳🇷|2.0|flag: Nauru|
Flags|🇳🇺|2.0|flag: Niue|
Flags|🇳🇿|2.0|flag: New Zealand|
Flags|🇴🇲|2.0|flag: Oman|
Flags|🇵🇦|2.0|flag: Panama|
Flags|🇵🇪|2.0|flag: Peru|
Flags|🇵🇫|2.0|flag: French Polynesia|
Flags|🇵🇬|2.0|flag: Papua New Guinea|
Flags|🇵🇭|2.0|flag: Philippines|
Flags|🇵🇰|2.0|flag: Pakistan|
Flags|🇵🇱|2.0|flag: Poland|
Flags|🇵🇲|2.0|flag: St. Pierre & Miquelon|
Flags|🇵🇳|2.0|flag: Pitcairn Islands|
Flags|🇵🇷|2.0|flag: Puerto Rico|
Flags|🇵🇸|2.0|flag: Palestinian Territories|
Flags|🇵🇹|2.0|flag: Portugal|
Flags|🇵🇼|2.0|flag: Palau|
Flags|🇵🇾|2.0|flag: Paraguay|
Flags|🇶🇦|2.0|flag: Qatar|
Flags|🇷🇪|2.0|flag: Réunion|
Flags|🇷🇴|2.0|flag: Romania|
Flags|🇷🇸|2.0|flag: Serbia|
Flags|🇷🇺|0.6|flag: Russia|
Flags|🇷🇼|2.0|flag: Rwanda|
Flags|🇸🇦|2.0|flag: Saudi Arabia|
Flags|🇸🇧|2.0|flag: Solomon Islands|
Flags|🇸🇨|2.0|flag: Seychelles|
Flags|🇸🇩|2.0|flag: Sudan|
Flags|🇸🇪|2.0|flag: Sweden|
Flags|🇸🇬|2.0|flag: Singapore|
Flags|🇸🇭|2.0|flag: St. Helena, Ascension & Tristan da Cunha|
Flags|🇸🇮|2.0|flag: Slovenia|
Flags|🇸🇯|2.0|flag: Svalbard & Jan Mayen|
Flags|🇸🇰|2.0|flag: Slovakia|
Flags|🇸🇱|2.0|flag: Sierra Leone|
Flags|🇸🇲|2.0|flag: San Marino|
Flags|🇸🇳|2.0|flag: Senegal|
Flags|🇸🇴|2.0|flag: Somalia|
Flags|🇸🇷|2.0|flag: Suriname|
Flags|🇸🇸|2.0|flag: South Sudan|
Flags|🇸🇹|2.0|flag: São Tomé & Príncipe|
Flags|🇸🇻|2.0|flag: El Salvador|
Flags|🇸🇽|2.0|flag: Sint Maarten|
Flags|🇸🇾|2.0|flag: Syria|
Flags|🇸🇿|2.0|flag: Eswatini|
Flags|🇹🇦|2.0|flag: Tristan da Cunha|
Flags|🇹🇨|2.0|flag: Turks & Caicos Islands|
Flags|🇹🇩|2.0|flag: Chad|
Flags|🇹🇫|2.0|flag: French Southern and Antarctic Lands|
Flags|🇹🇬|2.0|flag: Togo|
Flags|🇹🇭|2.0|flag: Thailand|
Flags|🇹🇯|2.0|flag: Tajikistan|
Flags|🇹🇰|2.0|flag: Tokelau|
Flags|🇹🇱|2.0|flag: Timor-Leste|
Flags|🇹🇲|2.0|flag: Turkmenistan|
Flags|🇹🇳|2.0|flag: Tunisia|
Flags|🇹🇴|2.0|flag: Tonga|
Flags|🇹🇷|2.0|flag: Türkiye|
Flags|🇹🇹|2.0|flag: Trinidad & Tobago|
Flags|🇹🇻|2.0|flag: Tuvalu|
Flags|🇹🇼|2.0|flag: Taiwan|
Flags|🇹🇿|2.0|flag: Tanzania|
Flags|🇺🇦|2.0|flag: Ukraine|
Flags|🇺🇬|2.0|flag: Uganda|
Flags|🇺🇲|2.0|flag: U.S. Outlying Islands|
Flags|🇺🇳|4.0|flag: United Nations|
Flags|🇺🇸|0.6|flag: United States|
Flags|🇺🇾|2.0|flag: Uruguay|
Flags|🇺🇿|2.0|flag: Uzbekistan|
Flags|🇻🇦|2.0|flag: Vatican City|
Flags|🇻🇨|2.0|flag: St. Vincent & Grenadines|
Flags|🇻🇪|2.0|flag: Venezuela|
Flags|🇻🇬|2.0|flag: British Virgin Islands|
Flags|🇻🇮|2.0|flag: U.S. Virgin Islands|
Flags|🇻🇳|2.0|flag: Vietnam|
Flags|🇻🇺|2.0|flag: Vanuatu|
Flags|🇼🇫|2.0|flag: Wallis & Futuna|
Flags|🇼🇸|2.0|flag: Samoa|
Flags|🇽🇰|2.0|flag: Kosovo|
Flags|🇾🇪|2.0|flag: Yemen|
Flags|🇾🇹|2.0|flag: Mayotte|
Flags|🇿🇦|2.0|flag: South Africa|
Flags|🇿🇲|2.0|flag: Zambia|
Flags|🇿🇼|2.0|flag: Zimbabwe|
Flags|🏴󠁧󠁢󠁥󠁮󠁧󠁿|5.0|flag: England|
Flags|🏴󠁧󠁢󠁳󠁣󠁴󠁿|5.0|flag: Scotland|
Flags|🏴󠁧󠁢󠁷󠁬󠁳󠁿|5.0|flag: Wales|
"""
}
