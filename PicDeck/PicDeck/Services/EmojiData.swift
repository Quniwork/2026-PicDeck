// 由 Unicode emoji-test.txt（18.0）產生：只留完整合格的表情，膚色與髮色變體由選擇器另外展開。
// 每行：分類|表情|加入的 Emoji 版本|英文名稱。
enum EmojiData {
    static let raw = """
Smileys & Emotion|😀|1.0|grinning face
Smileys & Emotion|😃|0.6|grinning face with big eyes
Smileys & Emotion|😄|0.6|grinning face with smiling eyes
Smileys & Emotion|😁|0.6|beaming face with smiling eyes
Smileys & Emotion|😆|0.6|grinning squinting face
Smileys & Emotion|😅|0.6|grinning face with sweat
Smileys & Emotion|🤣|3.0|rolling on the floor laughing
Smileys & Emotion|😂|0.6|face with tears of joy
Smileys & Emotion|🙂|1.0|slightly smiling face
Smileys & Emotion|🙃|1.0|upside-down face
Smileys & Emotion|🫠|14.0|melting face
Smileys & Emotion|🫫|18.0|cracking face
Smileys & Emotion|😉|0.6|winking face
Smileys & Emotion|😊|0.6|smiling face with smiling eyes
Smileys & Emotion|😇|1.0|smiling face with halo
Smileys & Emotion|🥰|11.0|smiling face with hearts
Smileys & Emotion|😍|0.6|smiling face with heart-eyes
Smileys & Emotion|🤩|5.0|star-struck
Smileys & Emotion|😘|0.6|face blowing a kiss
Smileys & Emotion|😗|1.0|kissing face
Smileys & Emotion|☺️|0.6|smiling face
Smileys & Emotion|😚|0.6|kissing face with closed eyes
Smileys & Emotion|😙|1.0|kissing face with smiling eyes
Smileys & Emotion|🥲|13.0|smiling face with tear
Smileys & Emotion|😋|0.6|face savoring food
Smileys & Emotion|😛|1.0|face with tongue
Smileys & Emotion|😜|0.6|winking face with tongue
Smileys & Emotion|🤪|5.0|zany face
Smileys & Emotion|😝|0.6|squinting face with tongue
Smileys & Emotion|🤑|1.0|money-mouth face
Smileys & Emotion|🤗|1.0|smiling face with open hands
Smileys & Emotion|🤭|5.0|face with hand over mouth
Smileys & Emotion|🫢|14.0|face with open eyes and hand over mouth
Smileys & Emotion|🫣|14.0|face with peeking eye
Smileys & Emotion|🤫|5.0|shushing face
Smileys & Emotion|🤔|1.0|thinking face
Smileys & Emotion|🫡|14.0|saluting face
Smileys & Emotion|🤐|1.0|zipper-mouth face
Smileys & Emotion|🤨|5.0|face with raised eyebrow
Smileys & Emotion|😐|0.7|neutral face
Smileys & Emotion|😑|1.0|expressionless face
Smileys & Emotion|😶|1.0|face without mouth
Smileys & Emotion|🫥|14.0|dotted line face
Smileys & Emotion|😶‍🌫️|13.1|face in clouds
Smileys & Emotion|😏|0.6|smirking face
Smileys & Emotion|😒|0.6|unamused face
Smileys & Emotion|🙄|1.0|face with rolling eyes
Smileys & Emotion|😬|1.0|grimacing face
Smileys & Emotion|😮‍💨|13.1|face exhaling
Smileys & Emotion|🤥|3.0|lying face
Smileys & Emotion|🫨|15.0|shaking face
Smileys & Emotion|🙂‍↔️|15.1|head shaking horizontally
Smileys & Emotion|🙂‍↕️|15.1|head shaking vertically
Smileys & Emotion|😌|0.6|relieved face
Smileys & Emotion|😔|0.6|pensive face
Smileys & Emotion|😪|0.6|sleepy face
Smileys & Emotion|🤤|3.0|drooling face
Smileys & Emotion|😴|1.0|sleeping face
Smileys & Emotion|🫩|16.0|face with bags under eyes
Smileys & Emotion|😷|0.6|face with medical mask
Smileys & Emotion|🤒|1.0|face with thermometer
Smileys & Emotion|🤕|1.0|face with head-bandage
Smileys & Emotion|🤢|3.0|nauseated face
Smileys & Emotion|🤮|5.0|face vomiting
Smileys & Emotion|🤧|3.0|sneezing face
Smileys & Emotion|🥵|11.0|hot face
Smileys & Emotion|🥶|11.0|cold face
Smileys & Emotion|🥴|11.0|woozy face
Smileys & Emotion|😵|0.6|face with crossed-out eyes
Smileys & Emotion|😵‍💫|13.1|face with spiral eyes
Smileys & Emotion|🤯|5.0|exploding head
Smileys & Emotion|🤠|3.0|cowboy hat face
Smileys & Emotion|🥳|11.0|partying face
Smileys & Emotion|🥸|13.0|disguised face
Smileys & Emotion|😎|1.0|smiling face with sunglasses
Smileys & Emotion|🤓|1.0|nerd face
Smileys & Emotion|🧐|5.0|face with monocle
Smileys & Emotion|😕|1.0|confused face
Smileys & Emotion|🫤|14.0|face with diagonal mouth
Smileys & Emotion|😟|1.0|worried face
Smileys & Emotion|🙁|1.0|slightly frowning face
Smileys & Emotion|☹️|0.7|frowning face
Smileys & Emotion|😮|1.0|face with open mouth
Smileys & Emotion|😯|1.0|hushed face
Smileys & Emotion|😲|0.6|astonished face
Smileys & Emotion|😳|0.6|flushed face
Smileys & Emotion|🫪|17.0|distorted face
Smileys & Emotion|🥺|11.0|pleading face
Smileys & Emotion|🥹|14.0|face holding back tears
Smileys & Emotion|😦|1.0|frowning face with open mouth
Smileys & Emotion|😧|1.0|anguished face
Smileys & Emotion|😨|0.6|fearful face
Smileys & Emotion|😰|0.6|anxious face with sweat
Smileys & Emotion|😥|0.6|sad but relieved face
Smileys & Emotion|😢|0.6|crying face
Smileys & Emotion|😭|0.6|loudly crying face
Smileys & Emotion|😱|0.6|face screaming in fear
Smileys & Emotion|😖|0.6|confounded face
Smileys & Emotion|😣|0.6|persevering face
Smileys & Emotion|😞|0.6|disappointed face
Smileys & Emotion|😓|0.6|downcast face with sweat
Smileys & Emotion|😩|0.6|weary face
Smileys & Emotion|😫|0.6|tired face
Smileys & Emotion|🥱|12.0|yawning face
Smileys & Emotion|😤|0.6|face with steam from nose
Smileys & Emotion|😡|0.6|enraged face
Smileys & Emotion|😠|0.6|angry face
Smileys & Emotion|🤬|5.0|face with symbols on mouth
Smileys & Emotion|😈|1.0|smiling face with horns
Smileys & Emotion|👿|0.6|angry face with horns
Smileys & Emotion|💀|0.6|skull
Smileys & Emotion|☠️|1.0|skull and crossbones
Smileys & Emotion|💩|0.6|pile of poo
Smileys & Emotion|🤡|3.0|clown face
Smileys & Emotion|👹|0.6|ogre
Smileys & Emotion|👺|0.6|goblin
Smileys & Emotion|👻|0.6|ghost
Smileys & Emotion|👽|0.6|alien
Smileys & Emotion|👾|0.6|alien monster
Smileys & Emotion|🤖|1.0|robot
Smileys & Emotion|😺|0.6|grinning cat
Smileys & Emotion|😸|0.6|grinning cat with smiling eyes
Smileys & Emotion|😹|0.6|cat with tears of joy
Smileys & Emotion|😻|0.6|smiling cat with heart-eyes
Smileys & Emotion|😼|0.6|cat with wry smile
Smileys & Emotion|😽|0.6|kissing cat
Smileys & Emotion|🙀|0.6|weary cat
Smileys & Emotion|😿|0.6|crying cat
Smileys & Emotion|😾|0.6|pouting cat
Smileys & Emotion|🙈|0.6|see-no-evil monkey
Smileys & Emotion|🙉|0.6|hear-no-evil monkey
Smileys & Emotion|🙊|0.6|speak-no-evil monkey
Smileys & Emotion|💌|0.6|love letter
Smileys & Emotion|💘|0.6|heart with arrow
Smileys & Emotion|💝|0.6|heart with ribbon
Smileys & Emotion|💖|0.6|sparkling heart
Smileys & Emotion|💗|0.6|growing heart
Smileys & Emotion|💓|0.6|beating heart
Smileys & Emotion|💞|0.6|revolving hearts
Smileys & Emotion|💕|0.6|two hearts
Smileys & Emotion|💟|0.6|heart decoration
Smileys & Emotion|❣️|1.0|heart exclamation
Smileys & Emotion|💔|0.6|broken heart
Smileys & Emotion|❤️‍🔥|13.1|heart on fire
Smileys & Emotion|❤️‍🩹|13.1|mending heart
Smileys & Emotion|❤️|0.6|red heart
Smileys & Emotion|🩷|15.0|pink heart
Smileys & Emotion|🧡|5.0|orange heart
Smileys & Emotion|💛|0.6|yellow heart
Smileys & Emotion|💚|0.6|green heart
Smileys & Emotion|💙|0.6|blue heart
Smileys & Emotion|🩵|15.0|light blue heart
Smileys & Emotion|💜|0.6|purple heart
Smileys & Emotion|🤎|12.0|brown heart
Smileys & Emotion|🖤|3.0|black heart
Smileys & Emotion|🩶|15.0|grey heart
Smileys & Emotion|🤍|12.0|white heart
Smileys & Emotion|💋|0.6|kiss mark
Smileys & Emotion|💯|0.6|hundred points
Smileys & Emotion|💢|0.6|anger symbol
Smileys & Emotion|🫯|17.0|fight cloud
Smileys & Emotion|💥|0.6|collision
Smileys & Emotion|💫|0.6|dizzy
Smileys & Emotion|💦|0.6|sweat droplets
Smileys & Emotion|💨|0.6|dashing away
Smileys & Emotion|🕳️|0.7|hole
Smileys & Emotion|💬|0.6|speech balloon
Smileys & Emotion|👁️‍🗨️|2.0|eye in speech bubble
Smileys & Emotion|🗨️|2.0|left speech bubble
Smileys & Emotion|🗯️|0.7|right anger bubble
Smileys & Emotion|💭|1.0|thought balloon
Smileys & Emotion|💤|0.6|ZZZ
People & Body|👋|0.6|waving hand
People & Body|🤚|3.0|raised back of hand
People & Body|🖐️|0.7|hand with fingers splayed
People & Body|✋|0.6|raised hand
People & Body|🖖|1.0|vulcan salute
People & Body|🫱|14.0|rightwards hand
People & Body|🫲|14.0|leftwards hand
People & Body|🫳|14.0|palm down hand
People & Body|🫴|14.0|palm up hand
People & Body|🫷|15.0|leftwards pushing hand
People & Body|🫸|15.0|rightwards pushing hand
People & Body|👌|0.6|OK hand
People & Body|🤌|13.0|pinched fingers
People & Body|🤏|12.0|pinching hand
People & Body|✌️|0.6|victory hand
People & Body|🤞|3.0|crossed fingers
People & Body|🫰|14.0|hand with index finger and thumb crossed
People & Body|🤟|5.0|love-you gesture
People & Body|🤘|1.0|sign of the horns
People & Body|🤙|3.0|call me hand
People & Body|👈|0.6|backhand index pointing left
People & Body|👉|0.6|backhand index pointing right
People & Body|👆|0.6|backhand index pointing up
People & Body|🖕|1.0|middle finger
People & Body|👇|0.6|backhand index pointing down
People & Body|☝️|0.6|index pointing up
People & Body|🫵|14.0|index pointing at the viewer
People & Body|👍|0.6|thumbs up
People & Body|👎|0.6|thumbs down
People & Body|🫹|18.0|leftwards thumb sign
People & Body|🫺|18.0|rightwards thumb sign
People & Body|✊|0.6|raised fist
People & Body|👊|0.6|oncoming fist
People & Body|🤛|3.0|left-facing fist
People & Body|🤜|3.0|right-facing fist
People & Body|👏|0.6|clapping hands
People & Body|🙌|0.6|raising hands
People & Body|🫶|14.0|heart hands
People & Body|👐|0.6|open hands
People & Body|🤲|5.0|palms up together
People & Body|🤝|3.0|handshake
People & Body|🙏|0.6|folded hands
People & Body|✍️|0.7|writing hand
People & Body|💅|0.6|nail polish
People & Body|🤳|3.0|selfie
People & Body|💪|0.6|flexed biceps
People & Body|🦾|12.0|mechanical arm
People & Body|🦿|12.0|mechanical leg
People & Body|🦵|11.0|leg
People & Body|🦶|11.0|foot
People & Body|👂|0.6|ear
People & Body|🦻|12.0|ear with hearing aid
People & Body|👃|0.6|nose
People & Body|🧠|5.0|brain
People & Body|🫀|13.0|anatomical heart
People & Body|🫁|13.0|lungs
People & Body|🦷|11.0|tooth
People & Body|🦴|11.0|bone
People & Body|👀|0.6|eyes
People & Body|👁️|0.7|eye
People & Body|👅|0.6|tongue
People & Body|👄|0.6|mouth
People & Body|🫦|14.0|biting lip
People & Body|👶|0.6|baby
People & Body|🧒|5.0|child
People & Body|👦|0.6|boy
People & Body|👧|0.6|girl
People & Body|🧑|5.0|person
People & Body|👱|0.6|person: blond hair
People & Body|👨|0.6|man
People & Body|🧔|5.0|person: beard
People & Body|🧔‍♂️|13.1|man: beard
People & Body|🧔‍♀️|13.1|woman: beard
People & Body|👩|0.6|woman
People & Body|👱‍♀️|4.0|woman: blond hair
People & Body|👱‍♂️|4.0|man: blond hair
People & Body|🧓|5.0|older person
People & Body|👴|0.6|old man
People & Body|👵|0.6|old woman
People & Body|🙍|0.6|person frowning
People & Body|🙍‍♂️|4.0|man frowning
People & Body|🙍‍♀️|4.0|woman frowning
People & Body|🙎|0.6|person pouting
People & Body|🙎‍♂️|4.0|man pouting
People & Body|🙎‍♀️|4.0|woman pouting
People & Body|🙅|0.6|person gesturing NO
People & Body|🙅‍♂️|4.0|man gesturing NO
People & Body|🙅‍♀️|4.0|woman gesturing NO
People & Body|🙆|0.6|person gesturing OK
People & Body|🙆‍♂️|4.0|man gesturing OK
People & Body|🙆‍♀️|4.0|woman gesturing OK
People & Body|💁|0.6|person tipping hand
People & Body|💁‍♂️|4.0|man tipping hand
People & Body|💁‍♀️|4.0|woman tipping hand
People & Body|🙋|0.6|person raising hand
People & Body|🙋‍♂️|4.0|man raising hand
People & Body|🙋‍♀️|4.0|woman raising hand
People & Body|🧏|12.0|deaf person
People & Body|🧏‍♂️|12.0|deaf man
People & Body|🧏‍♀️|12.0|deaf woman
People & Body|🙇|0.6|person bowing
People & Body|🙇‍♂️|4.0|man bowing
People & Body|🙇‍♀️|4.0|woman bowing
People & Body|🤦|3.0|person facepalming
People & Body|🤦‍♂️|4.0|man facepalming
People & Body|🤦‍♀️|4.0|woman facepalming
People & Body|🤷|3.0|person shrugging
People & Body|🤷‍♂️|4.0|man shrugging
People & Body|🤷‍♀️|4.0|woman shrugging
People & Body|🧑‍⚕️|12.1|health worker
People & Body|👨‍⚕️|4.0|man health worker
People & Body|👩‍⚕️|4.0|woman health worker
People & Body|🧑‍🎓|12.1|student
People & Body|👨‍🎓|4.0|man student
People & Body|👩‍🎓|4.0|woman student
People & Body|🧑‍🏫|12.1|teacher
People & Body|👨‍🏫|4.0|man teacher
People & Body|👩‍🏫|4.0|woman teacher
People & Body|🧑‍⚖️|12.1|judge
People & Body|👨‍⚖️|4.0|man judge
People & Body|👩‍⚖️|4.0|woman judge
People & Body|🧑‍🌾|12.1|farmer
People & Body|👨‍🌾|4.0|man farmer
People & Body|👩‍🌾|4.0|woman farmer
People & Body|🧑‍🍳|12.1|cook
People & Body|👨‍🍳|4.0|man cook
People & Body|👩‍🍳|4.0|woman cook
People & Body|🧑‍🔧|12.1|mechanic
People & Body|👨‍🔧|4.0|man mechanic
People & Body|👩‍🔧|4.0|woman mechanic
People & Body|🧑‍🏭|12.1|factory worker
People & Body|👨‍🏭|4.0|man factory worker
People & Body|👩‍🏭|4.0|woman factory worker
People & Body|🧑‍💼|12.1|office worker
People & Body|👨‍💼|4.0|man office worker
People & Body|👩‍💼|4.0|woman office worker
People & Body|🧑‍🔬|12.1|scientist
People & Body|👨‍🔬|4.0|man scientist
People & Body|👩‍🔬|4.0|woman scientist
People & Body|🧑‍💻|12.1|technologist
People & Body|👨‍💻|4.0|man technologist
People & Body|👩‍💻|4.0|woman technologist
People & Body|🧑‍🎤|12.1|singer
People & Body|👨‍🎤|4.0|man singer
People & Body|👩‍🎤|4.0|woman singer
People & Body|🧑‍🎨|12.1|artist
People & Body|👨‍🎨|4.0|man artist
People & Body|👩‍🎨|4.0|woman artist
People & Body|🧑‍✈️|12.1|pilot
People & Body|👨‍✈️|4.0|man pilot
People & Body|👩‍✈️|4.0|woman pilot
People & Body|🧑‍🚀|12.1|astronaut
People & Body|👨‍🚀|4.0|man astronaut
People & Body|👩‍🚀|4.0|woman astronaut
People & Body|🧑‍🚒|12.1|firefighter
People & Body|👨‍🚒|4.0|man firefighter
People & Body|👩‍🚒|4.0|woman firefighter
People & Body|👮|0.6|police officer
People & Body|👮‍♂️|4.0|man police officer
People & Body|👮‍♀️|4.0|woman police officer
People & Body|🕵️|0.7|detective
People & Body|🕵️‍♂️|4.0|man detective
People & Body|🕵️‍♀️|4.0|woman detective
People & Body|💂|0.6|guard
People & Body|💂‍♂️|4.0|man guard
People & Body|💂‍♀️|4.0|woman guard
People & Body|🥷|13.0|ninja
People & Body|👷|0.6|construction worker
People & Body|👷‍♂️|4.0|man construction worker
People & Body|👷‍♀️|4.0|woman construction worker
People & Body|🫅|14.0|person with crown
People & Body|🤴|3.0|prince
People & Body|👸|0.6|princess
People & Body|👳|0.6|person wearing turban
People & Body|👳‍♂️|4.0|man wearing turban
People & Body|👳‍♀️|4.0|woman wearing turban
People & Body|👲|0.6|person with skullcap
People & Body|🧕|5.0|woman with headscarf
People & Body|🤵|3.0|person in tuxedo
People & Body|🤵‍♂️|13.0|man in tuxedo
People & Body|🤵‍♀️|13.0|woman in tuxedo
People & Body|👰|0.6|person with veil
People & Body|👰‍♂️|13.0|man with veil
People & Body|👰‍♀️|13.0|woman with veil
People & Body|🤰|3.0|pregnant woman
People & Body|🫃|14.0|pregnant man
People & Body|🫄|14.0|pregnant person
People & Body|🤱|5.0|breast-feeding
People & Body|👩‍🍼|13.0|woman feeding baby
People & Body|👨‍🍼|13.0|man feeding baby
People & Body|🧑‍🍼|13.0|person feeding baby
People & Body|👼|0.6|baby angel
People & Body|🎅|0.6|Santa Claus
People & Body|🤶|3.0|Mrs. Claus
People & Body|🧑‍🎄|13.0|Mx Claus
People & Body|🦸|11.0|superhero
People & Body|🦸‍♂️|11.0|man superhero
People & Body|🦸‍♀️|11.0|woman superhero
People & Body|🦹|11.0|supervillain
People & Body|🦹‍♂️|11.0|man supervillain
People & Body|🦹‍♀️|11.0|woman supervillain
People & Body|🧙|5.0|mage
People & Body|🧙‍♂️|5.0|man mage
People & Body|🧙‍♀️|5.0|woman mage
People & Body|🧚|5.0|fairy
People & Body|🧚‍♂️|5.0|man fairy
People & Body|🧚‍♀️|5.0|woman fairy
People & Body|🧛|5.0|vampire
People & Body|🧛‍♂️|5.0|man vampire
People & Body|🧛‍♀️|5.0|woman vampire
People & Body|🧜|5.0|merperson
People & Body|🧜‍♂️|5.0|merman
People & Body|🧜‍♀️|5.0|mermaid
People & Body|🧝|5.0|elf
People & Body|🧝‍♂️|5.0|man elf
People & Body|🧝‍♀️|5.0|woman elf
People & Body|🧞|5.0|genie
People & Body|🧞‍♂️|5.0|man genie
People & Body|🧞‍♀️|5.0|woman genie
People & Body|🧟|5.0|zombie
People & Body|🧟‍♂️|5.0|man zombie
People & Body|🧟‍♀️|5.0|woman zombie
People & Body|🧌|14.0|troll
People & Body|🫈|17.0|hairy creature
People & Body|💆|0.6|person getting massage
People & Body|💆‍♂️|4.0|man getting massage
People & Body|💆‍♀️|4.0|woman getting massage
People & Body|💇|0.6|person getting haircut
People & Body|💇‍♂️|4.0|man getting haircut
People & Body|💇‍♀️|4.0|woman getting haircut
People & Body|🚶|0.6|person walking
People & Body|🚶‍♂️|4.0|man walking
People & Body|🚶‍♀️|4.0|woman walking
People & Body|🚶‍➡️|15.1|person walking facing right
People & Body|🚶‍♀️‍➡️|15.1|woman walking facing right
People & Body|🚶‍♂️‍➡️|15.1|man walking facing right
People & Body|🧍|12.0|person standing
People & Body|🧍‍♂️|12.0|man standing
People & Body|🧍‍♀️|12.0|woman standing
People & Body|🧎|12.0|person kneeling
People & Body|🧎‍♂️|12.0|man kneeling
People & Body|🧎‍♀️|12.0|woman kneeling
People & Body|🧎‍➡️|15.1|person kneeling facing right
People & Body|🧎‍♀️‍➡️|15.1|woman kneeling facing right
People & Body|🧎‍♂️‍➡️|15.1|man kneeling facing right
People & Body|🧑‍🦯|12.1|person with white cane
People & Body|🧑‍🦯‍➡️|15.1|person with white cane facing right
People & Body|👨‍🦯|12.0|man with white cane
People & Body|👨‍🦯‍➡️|15.1|man with white cane facing right
People & Body|👩‍🦯|12.0|woman with white cane
People & Body|👩‍🦯‍➡️|15.1|woman with white cane facing right
People & Body|🧑‍🦼|12.1|person in motorized wheelchair
People & Body|🧑‍🦼‍➡️|15.1|person in motorized wheelchair facing right
People & Body|👨‍🦼|12.0|man in motorized wheelchair
People & Body|👨‍🦼‍➡️|15.1|man in motorized wheelchair facing right
People & Body|👩‍🦼|12.0|woman in motorized wheelchair
People & Body|👩‍🦼‍➡️|15.1|woman in motorized wheelchair facing right
People & Body|🧑‍🦽|12.1|person in manual wheelchair
People & Body|🧑‍🦽‍➡️|15.1|person in manual wheelchair facing right
People & Body|👨‍🦽|12.0|man in manual wheelchair
People & Body|👨‍🦽‍➡️|15.1|man in manual wheelchair facing right
People & Body|👩‍🦽|12.0|woman in manual wheelchair
People & Body|👩‍🦽‍➡️|15.1|woman in manual wheelchair facing right
People & Body|🏃|0.6|person running
People & Body|🏃‍♂️|4.0|man running
People & Body|🏃‍♀️|4.0|woman running
People & Body|🏃‍➡️|15.1|person running facing right
People & Body|🏃‍♀️‍➡️|15.1|woman running facing right
People & Body|🏃‍♂️‍➡️|15.1|man running facing right
People & Body|🧑‍🩰|17.0|ballet dancer
People & Body|💃|0.6|woman dancing
People & Body|🕺|3.0|man dancing
People & Body|🕴️|0.7|person in suit levitating
People & Body|👯|0.6|people with bunny ears
People & Body|👯‍♂️|4.0|men with bunny ears
People & Body|👯‍♀️|4.0|women with bunny ears
People & Body|🧖|5.0|person in steamy room
People & Body|🧖‍♂️|5.0|man in steamy room
People & Body|🧖‍♀️|5.0|woman in steamy room
People & Body|🧗|5.0|person climbing
People & Body|🧗‍♂️|5.0|man climbing
People & Body|🧗‍♀️|5.0|woman climbing
People & Body|🤺|3.0|person fencing
People & Body|🏇|1.0|horse racing
People & Body|⛷️|0.7|skier
People & Body|🏂|0.6|snowboarder
People & Body|🏌️|0.7|person golfing
People & Body|🏌️‍♂️|4.0|man golfing
People & Body|🏌️‍♀️|4.0|woman golfing
People & Body|🏄|0.6|person surfing
People & Body|🏄‍♂️|4.0|man surfing
People & Body|🏄‍♀️|4.0|woman surfing
People & Body|🚣|1.0|person rowing boat
People & Body|🚣‍♂️|4.0|man rowing boat
People & Body|🚣‍♀️|4.0|woman rowing boat
People & Body|🏊|0.6|person swimming
People & Body|🏊‍♂️|4.0|man swimming
People & Body|🏊‍♀️|4.0|woman swimming
People & Body|⛹️|0.7|person bouncing ball
People & Body|⛹️‍♂️|4.0|man bouncing ball
People & Body|⛹️‍♀️|4.0|woman bouncing ball
People & Body|🏋️|0.7|person lifting weights
People & Body|🏋️‍♂️|4.0|man lifting weights
People & Body|🏋️‍♀️|4.0|woman lifting weights
People & Body|🚴|1.0|person biking
People & Body|🚴‍♂️|4.0|man biking
People & Body|🚴‍♀️|4.0|woman biking
People & Body|🚵|1.0|person mountain biking
People & Body|🚵‍♂️|4.0|man mountain biking
People & Body|🚵‍♀️|4.0|woman mountain biking
People & Body|🤸|3.0|person cartwheeling
People & Body|🤸‍♂️|4.0|man cartwheeling
People & Body|🤸‍♀️|4.0|woman cartwheeling
People & Body|🤼|3.0|people wrestling
People & Body|🤼‍♂️|4.0|men wrestling
People & Body|🤼‍♀️|4.0|women wrestling
People & Body|🤽|3.0|person playing water polo
People & Body|🤽‍♂️|4.0|man playing water polo
People & Body|🤽‍♀️|4.0|woman playing water polo
People & Body|🤾|3.0|person playing handball
People & Body|🤾‍♂️|4.0|man playing handball
People & Body|🤾‍♀️|4.0|woman playing handball
People & Body|🤹|3.0|person juggling
People & Body|🤹‍♂️|4.0|man juggling
People & Body|🤹‍♀️|4.0|woman juggling
People & Body|🧘|5.0|person in lotus position
People & Body|🧘‍♂️|5.0|man in lotus position
People & Body|🧘‍♀️|5.0|woman in lotus position
People & Body|🛀|0.6|person taking bath
People & Body|🛌|1.0|person in bed
People & Body|🧑‍🤝‍🧑|12.0|people holding hands
People & Body|👭|1.0|women holding hands
People & Body|👫|0.6|woman and man holding hands
People & Body|👬|1.0|men holding hands
People & Body|💏|0.6|kiss
People & Body|👩‍❤️‍💋‍👨|2.0|kiss: woman, man
People & Body|👨‍❤️‍💋‍👨|2.0|kiss: man, man
People & Body|👩‍❤️‍💋‍👩|2.0|kiss: woman, woman
People & Body|💑|0.6|couple with heart
People & Body|👩‍❤️‍👨|2.0|couple with heart: woman, man
People & Body|👨‍❤️‍👨|2.0|couple with heart: man, man
People & Body|👩‍❤️‍👩|2.0|couple with heart: woman, woman
People & Body|👨‍👩‍👦|2.0|family: man, woman, boy
People & Body|👨‍👩‍👧|2.0|family: man, woman, girl
People & Body|👨‍👩‍👧‍👦|2.0|family: man, woman, girl, boy
People & Body|👨‍👩‍👦‍👦|2.0|family: man, woman, boy, boy
People & Body|👨‍👩‍👧‍👧|2.0|family: man, woman, girl, girl
People & Body|👨‍👨‍👦|2.0|family: man, man, boy
People & Body|👨‍👨‍👧|2.0|family: man, man, girl
People & Body|👨‍👨‍👧‍👦|2.0|family: man, man, girl, boy
People & Body|👨‍👨‍👦‍👦|2.0|family: man, man, boy, boy
People & Body|👨‍👨‍👧‍👧|2.0|family: man, man, girl, girl
People & Body|👩‍👩‍👦|2.0|family: woman, woman, boy
People & Body|👩‍👩‍👧|2.0|family: woman, woman, girl
People & Body|👩‍👩‍👧‍👦|2.0|family: woman, woman, girl, boy
People & Body|👩‍👩‍👦‍👦|2.0|family: woman, woman, boy, boy
People & Body|👩‍👩‍👧‍👧|2.0|family: woman, woman, girl, girl
People & Body|👨‍👦|4.0|family: man, boy
People & Body|👨‍👦‍👦|4.0|family: man, boy, boy
People & Body|👨‍👧|4.0|family: man, girl
People & Body|👨‍👧‍👦|4.0|family: man, girl, boy
People & Body|👨‍👧‍👧|4.0|family: man, girl, girl
People & Body|👩‍👦|4.0|family: woman, boy
People & Body|👩‍👦‍👦|4.0|family: woman, boy, boy
People & Body|👩‍👧|4.0|family: woman, girl
People & Body|👩‍👧‍👦|4.0|family: woman, girl, boy
People & Body|👩‍👧‍👧|4.0|family: woman, girl, girl
People & Body|🗣️|0.7|speaking head
People & Body|👤|0.6|bust in silhouette
People & Body|👥|1.0|busts in silhouette
People & Body|🫂|13.0|people hugging
People & Body|👪|0.6|family
People & Body|🧑‍🧑‍🧒|15.1|family: adult, adult, child
People & Body|🧑‍🧑‍🧒‍🧒|15.1|family: adult, adult, child, child
People & Body|🧑‍🧒|15.1|family: adult, child
People & Body|🧑‍🧒‍🧒|15.1|family: adult, child, child
People & Body|👣|0.6|footprints
People & Body|🫆|16.0|fingerprint
Animals & Nature|🐵|0.6|monkey face
Animals & Nature|🐒|0.6|monkey
Animals & Nature|🦍|3.0|gorilla
Animals & Nature|🦧|12.0|orangutan
Animals & Nature|🐶|0.6|dog face
Animals & Nature|🐕|0.7|dog
Animals & Nature|🦮|12.0|guide dog
Animals & Nature|🐕‍🦺|12.0|service dog
Animals & Nature|🐩|0.6|poodle
Animals & Nature|🐺|0.6|wolf
Animals & Nature|🦊|3.0|fox
Animals & Nature|🦝|11.0|raccoon
Animals & Nature|🐱|0.6|cat face
Animals & Nature|🐈|0.7|cat
Animals & Nature|🐈‍⬛|13.0|black cat
Animals & Nature|🦁|1.0|lion
Animals & Nature|🐯|0.6|tiger face
Animals & Nature|🐅|1.0|tiger
Animals & Nature|🐆|1.0|leopard
Animals & Nature|🐴|0.6|horse face
Animals & Nature|🫎|15.0|moose
Animals & Nature|🫏|15.0|donkey
Animals & Nature|🐎|0.6|horse
Animals & Nature|🦄|1.0|unicorn
Animals & Nature|🦓|5.0|zebra
Animals & Nature|🦌|3.0|deer
Animals & Nature|🦬|13.0|bison
Animals & Nature|🐮|0.6|cow face
Animals & Nature|🐂|1.0|ox
Animals & Nature|🐃|1.0|water buffalo
Animals & Nature|🐄|1.0|cow
Animals & Nature|🐷|0.6|pig face
Animals & Nature|🐖|1.0|pig
Animals & Nature|🐗|0.6|boar
Animals & Nature|🐽|0.6|pig nose
Animals & Nature|🐏|1.0|ram
Animals & Nature|🐑|0.6|ewe
Animals & Nature|🐐|1.0|goat
Animals & Nature|🐪|1.0|camel
Animals & Nature|🐫|0.6|two-hump camel
Animals & Nature|🦙|11.0|llama
Animals & Nature|🦒|5.0|giraffe
Animals & Nature|🐘|0.6|elephant
Animals & Nature|🦣|13.0|mammoth
Animals & Nature|🦏|3.0|rhinoceros
Animals & Nature|🦛|11.0|hippopotamus
Animals & Nature|🐭|0.6|mouse face
Animals & Nature|🐁|1.0|mouse
Animals & Nature|🐀|1.0|rat
Animals & Nature|🐹|0.6|hamster
Animals & Nature|🐰|0.6|rabbit face
Animals & Nature|🐇|1.0|rabbit
Animals & Nature|🐿️|0.7|chipmunk
Animals & Nature|🦫|13.0|beaver
Animals & Nature|🦔|5.0|hedgehog
Animals & Nature|🦇|3.0|bat
Animals & Nature|🐻|0.6|bear
Animals & Nature|🐻‍❄️|13.0|polar bear
Animals & Nature|🐨|0.6|koala
Animals & Nature|🐼|0.6|panda
Animals & Nature|🦥|12.0|sloth
Animals & Nature|🦦|12.0|otter
Animals & Nature|🦨|12.0|skunk
Animals & Nature|🦘|11.0|kangaroo
Animals & Nature|🦡|11.0|badger
Animals & Nature|🐾|0.6|paw prints
Animals & Nature|🦃|1.0|turkey
Animals & Nature|🐔|0.6|chicken
Animals & Nature|🐓|1.0|rooster
Animals & Nature|🐣|0.6|hatching chick
Animals & Nature|🐤|0.6|baby chick
Animals & Nature|🐥|0.6|front-facing baby chick
Animals & Nature|🐦|0.6|bird
Animals & Nature|🐧|0.6|penguin
Animals & Nature|🕊️|0.7|dove
Animals & Nature|🦅|3.0|eagle
Animals & Nature|🦆|3.0|duck
Animals & Nature|🦢|11.0|swan
Animals & Nature|🦉|3.0|owl
Animals & Nature|🦤|13.0|dodo
Animals & Nature|🪶|13.0|feather
Animals & Nature|🦩|12.0|flamingo
Animals & Nature|🦚|11.0|peacock
Animals & Nature|🦜|11.0|parrot
Animals & Nature|🪽|15.0|wing
Animals & Nature|🐦‍⬛|15.0|black bird
Animals & Nature|🪿|15.0|goose
Animals & Nature|🐦‍🔥|15.1|phoenix
Animals & Nature|🐸|0.6|frog
Animals & Nature|🐊|1.0|crocodile
Animals & Nature|🐢|0.6|turtle
Animals & Nature|🦎|3.0|lizard
Animals & Nature|🐍|0.6|snake
Animals & Nature|🐲|0.6|dragon face
Animals & Nature|🐉|1.0|dragon
Animals & Nature|🦕|5.0|sauropod
Animals & Nature|🦖|5.0|T-Rex
Animals & Nature|🐳|0.6|spouting whale
Animals & Nature|🐋|1.0|whale
Animals & Nature|🐬|0.6|dolphin
Animals & Nature|🫍|17.0|orca
Animals & Nature|🦭|13.0|seal
Animals & Nature|🐟|0.6|fish
Animals & Nature|🐠|0.6|tropical fish
Animals & Nature|🐡|0.6|blowfish
Animals & Nature|🦈|3.0|shark
Animals & Nature|🐙|0.6|octopus
Animals & Nature|🐚|0.6|spiral shell
Animals & Nature|🪸|14.0|coral
Animals & Nature|🪼|15.0|jellyfish
Animals & Nature|🦀|1.0|crab
Animals & Nature|🦞|11.0|lobster
Animals & Nature|🦐|3.0|shrimp
Animals & Nature|🦑|3.0|squid
Animals & Nature|🦪|12.0|oyster
Animals & Nature|🐌|0.6|snail
Animals & Nature|🦋|3.0|butterfly
Animals & Nature|🫌|18.0|monarch butterfly
Animals & Nature|🐛|0.6|bug
Animals & Nature|🐜|0.6|ant
Animals & Nature|🐝|0.6|honeybee
Animals & Nature|🪲|13.0|beetle
Animals & Nature|🐞|0.6|lady beetle
Animals & Nature|🦗|5.0|cricket
Animals & Nature|🪳|13.0|cockroach
Animals & Nature|🕷️|0.7|spider
Animals & Nature|🕸️|0.7|spider web
Animals & Nature|🦂|1.0|scorpion
Animals & Nature|🦟|11.0|mosquito
Animals & Nature|🪰|13.0|fly
Animals & Nature|🪱|13.0|worm
Animals & Nature|🦠|11.0|microbe
Animals & Nature|💐|0.6|bouquet
Animals & Nature|🌸|0.6|cherry blossom
Animals & Nature|💮|0.6|white flower
Animals & Nature|🪷|14.0|lotus
Animals & Nature|🏵️|0.7|rosette
Animals & Nature|🌹|0.6|rose
Animals & Nature|🥀|3.0|wilted flower
Animals & Nature|🌺|0.6|hibiscus
Animals & Nature|🌻|0.6|sunflower
Animals & Nature|🌼|0.6|blossom
Animals & Nature|🌷|0.6|tulip
Animals & Nature|🪻|15.0|hyacinth
Animals & Nature|🌱|0.6|seedling
Animals & Nature|🪴|13.0|potted plant
Animals & Nature|🌲|1.0|evergreen tree
Animals & Nature|🌳|1.0|deciduous tree
Animals & Nature|🌴|0.6|palm tree
Animals & Nature|🌵|0.6|cactus
Animals & Nature|🌾|0.6|sheaf of rice
Animals & Nature|🌿|0.6|herb
Animals & Nature|☘️|1.0|shamrock
Animals & Nature|🍀|0.6|four leaf clover
Animals & Nature|🍁|0.6|maple leaf
Animals & Nature|🍂|0.6|fallen leaf
Animals & Nature|🍃|0.6|leaf fluttering in wind
Animals & Nature|🪹|14.0|empty nest
Animals & Nature|🪺|14.0|nest with eggs
Animals & Nature|🍄|0.6|mushroom
Animals & Nature|🪾|16.0|leafless tree
Food & Drink|🍇|0.6|grapes
Food & Drink|🍈|0.6|melon
Food & Drink|🍉|0.6|watermelon
Food & Drink|🍊|0.6|tangerine
Food & Drink|🍋|1.0|lemon
Food & Drink|🍋‍🟩|15.1|lime
Food & Drink|🍌|0.6|banana
Food & Drink|🍍|0.6|pineapple
Food & Drink|🥭|11.0|mango
Food & Drink|🍎|0.6|red apple
Food & Drink|🍏|0.6|green apple
Food & Drink|🍐|1.0|pear
Food & Drink|🍑|0.6|peach
Food & Drink|🍒|0.6|cherries
Food & Drink|🍓|0.6|strawberry
Food & Drink|🫐|13.0|blueberries
Food & Drink|🥝|3.0|kiwi fruit
Food & Drink|🍅|0.6|tomato
Food & Drink|🫒|13.0|olive
Food & Drink|🥥|5.0|coconut
Food & Drink|🥑|3.0|avocado
Food & Drink|🍆|0.6|eggplant
Food & Drink|🥔|3.0|potato
Food & Drink|🥕|3.0|carrot
Food & Drink|🌽|0.6|ear of corn
Food & Drink|🌶️|0.7|hot pepper
Food & Drink|🫑|13.0|bell pepper
Food & Drink|🥒|3.0|cucumber
Food & Drink|🫝|18.0|pickle
Food & Drink|🥬|11.0|leafy green
Food & Drink|🥦|5.0|broccoli
Food & Drink|🧄|12.0|garlic
Food & Drink|🧅|12.0|onion
Food & Drink|🥜|3.0|peanuts
Food & Drink|🫘|14.0|beans
Food & Drink|🌰|0.6|chestnut
Food & Drink|🫚|15.0|ginger root
Food & Drink|🫛|15.0|pea pod
Food & Drink|🍄‍🟫|15.1|brown mushroom
Food & Drink|🫜|16.0|root vegetable
Food & Drink|🍞|0.6|bread
Food & Drink|🥐|3.0|croissant
Food & Drink|🥖|3.0|baguette bread
Food & Drink|🫓|13.0|flatbread
Food & Drink|🥨|5.0|pretzel
Food & Drink|🥯|11.0|bagel
Food & Drink|🥞|3.0|pancakes
Food & Drink|🧇|12.0|waffle
Food & Drink|🧀|1.0|cheese wedge
Food & Drink|🍖|0.6|meat on bone
Food & Drink|🍗|0.6|poultry leg
Food & Drink|🥩|5.0|cut of meat
Food & Drink|🥓|3.0|bacon
Food & Drink|🍔|0.6|hamburger
Food & Drink|🍟|0.6|french fries
Food & Drink|🍕|0.6|pizza
Food & Drink|🌭|1.0|hot dog
Food & Drink|🥪|5.0|sandwich
Food & Drink|🌮|1.0|taco
Food & Drink|🌯|1.0|burrito
Food & Drink|🫔|13.0|tamale
Food & Drink|🥙|3.0|stuffed flatbread
Food & Drink|🧆|12.0|falafel
Food & Drink|🥚|3.0|egg
Food & Drink|🍳|0.6|cooking
Food & Drink|🥘|3.0|shallow pan of food
Food & Drink|🍲|0.6|pot of food
Food & Drink|🫕|13.0|fondue
Food & Drink|🥣|5.0|bowl with spoon
Food & Drink|🥗|3.0|green salad
Food & Drink|🍿|1.0|popcorn
Food & Drink|🧈|12.0|butter
Food & Drink|🧂|11.0|salt
Food & Drink|🥫|5.0|canned food
Food & Drink|🍱|0.6|bento box
Food & Drink|🍘|0.6|rice cracker
Food & Drink|🍙|0.6|rice ball
Food & Drink|🍚|0.6|cooked rice
Food & Drink|🍛|0.6|curry rice
Food & Drink|🍜|0.6|steaming bowl
Food & Drink|🍝|0.6|spaghetti
Food & Drink|🍠|0.6|roasted sweet potato
Food & Drink|🍢|0.6|oden
Food & Drink|🍣|0.6|sushi
Food & Drink|🍤|0.6|fried shrimp
Food & Drink|🍥|0.6|fish cake with swirl
Food & Drink|🥮|11.0|moon cake
Food & Drink|🍡|0.6|dango
Food & Drink|🥟|5.0|dumpling
Food & Drink|🥠|5.0|fortune cookie
Food & Drink|🥡|5.0|takeout box
Food & Drink|🍦|0.6|soft ice cream
Food & Drink|🍧|0.6|shaved ice
Food & Drink|🍨|0.6|ice cream
Food & Drink|🍩|0.6|doughnut
Food & Drink|🍪|0.6|cookie
Food & Drink|🎂|0.6|birthday cake
Food & Drink|🍰|0.6|shortcake
Food & Drink|🧁|11.0|cupcake
Food & Drink|🥧|5.0|pie
Food & Drink|🍫|0.6|chocolate bar
Food & Drink|🍬|0.6|candy
Food & Drink|🍭|0.6|lollipop
Food & Drink|🍮|0.6|custard
Food & Drink|🍯|0.6|honey pot
Food & Drink|🍼|1.0|baby bottle
Food & Drink|🥛|3.0|glass of milk
Food & Drink|☕|0.6|hot beverage
Food & Drink|🫖|13.0|teapot
Food & Drink|🍵|0.6|teacup without handle
Food & Drink|🍶|0.6|sake
Food & Drink|🍾|1.0|bottle with popping cork
Food & Drink|🍷|0.6|wine glass
Food & Drink|🍸|0.6|cocktail glass
Food & Drink|🍹|0.6|tropical drink
Food & Drink|🍺|0.6|beer mug
Food & Drink|🍻|0.6|clinking beer mugs
Food & Drink|🥂|3.0|clinking glasses
Food & Drink|🥃|3.0|tumbler glass
Food & Drink|🫗|14.0|pouring liquid
Food & Drink|🥤|5.0|cup with straw
Food & Drink|🧋|13.0|bubble tea
Food & Drink|🧃|12.0|beverage box
Food & Drink|🧉|12.0|mate
Food & Drink|🧊|12.0|ice
Food & Drink|🥢|5.0|chopsticks
Food & Drink|🍽️|0.7|fork and knife with plate
Food & Drink|🍴|0.6|fork and knife
Food & Drink|🥄|3.0|spoon
Food & Drink|🔪|0.6|kitchen knife
Food & Drink|🫙|14.0|jar
Food & Drink|🏺|1.0|amphora
Travel & Places|🌍|0.7|globe showing Europe-Africa
Travel & Places|🌎|0.7|globe showing Americas
Travel & Places|🌏|0.6|globe showing Asia-Australia
Travel & Places|🌐|1.0|globe with meridians
Travel & Places|🗺️|0.7|world map
Travel & Places|🗾|0.6|map of Japan
Travel & Places|🧭|11.0|compass
Travel & Places|🏔️|0.7|snow-capped mountain
Travel & Places|⛰️|0.7|mountain
Travel & Places|🛘|17.0|landslide
Travel & Places|🌋|0.6|volcano
Travel & Places|🗻|0.6|mount fuji
Travel & Places|🏕️|0.7|camping
Travel & Places|🏖️|0.7|beach with umbrella
Travel & Places|🏜️|0.7|desert
Travel & Places|🏝️|0.7|desert island
Travel & Places|🏞️|0.7|national park
Travel & Places|🏟️|0.7|stadium
Travel & Places|🏛️|0.7|classical building
Travel & Places|🏗️|0.7|building construction
Travel & Places|🧱|11.0|brick
Travel & Places|🪨|13.0|rock
Travel & Places|🪵|13.0|wood
Travel & Places|🛖|13.0|hut
Travel & Places|🏘️|0.7|houses
Travel & Places|🏚️|0.7|derelict house
Travel & Places|🏠|0.6|house
Travel & Places|🏡|0.6|house with garden
Travel & Places|🏢|0.6|office building
Travel & Places|🏣|0.6|Japanese post office
Travel & Places|🏤|1.0|post office
Travel & Places|🏥|0.6|hospital
Travel & Places|🏦|0.6|bank
Travel & Places|🏨|0.6|hotel
Travel & Places|🏩|0.6|love hotel
Travel & Places|🏪|0.6|convenience store
Travel & Places|🏫|0.6|school
Travel & Places|🏬|0.6|department store
Travel & Places|🏭|0.6|factory
Travel & Places|🏯|0.6|Japanese castle
Travel & Places|🏰|0.6|castle
Travel & Places|💒|0.6|wedding
Travel & Places|🗼|0.6|Tokyo tower
Travel & Places|🗽|0.6|Statue of Liberty
Travel & Places|⛪|0.6|church
Travel & Places|🕌|1.0|mosque
Travel & Places|🛕|12.0|hindu temple
Travel & Places|🕍|1.0|synagogue
Travel & Places|⛩️|0.7|shinto shrine
Travel & Places|🕋|1.0|kaaba
Travel & Places|⛲|0.6|fountain
Travel & Places|⛺|0.6|tent
Travel & Places|🌁|0.6|foggy
Travel & Places|🌃|0.6|night with stars
Travel & Places|🏙️|0.7|cityscape
Travel & Places|🌄|0.6|sunrise over mountains
Travel & Places|🌅|0.6|sunrise
Travel & Places|🌆|0.6|cityscape at dusk
Travel & Places|🌇|0.6|sunset
Travel & Places|🌉|0.6|bridge at night
Travel & Places|♨️|0.6|hot springs
Travel & Places|🎠|0.6|carousel horse
Travel & Places|🛝|14.0|playground slide
Travel & Places|🎡|0.6|ferris wheel
Travel & Places|🎢|0.6|roller coaster
Travel & Places|💈|0.6|barber pole
Travel & Places|🎪|0.6|circus tent
Travel & Places|🚂|1.0|locomotive
Travel & Places|🚃|0.6|railway car
Travel & Places|🚄|0.6|high-speed train
Travel & Places|🚅|0.6|bullet train
Travel & Places|🚆|1.0|train
Travel & Places|🚇|0.6|metro
Travel & Places|🚈|1.0|light rail
Travel & Places|🚉|0.6|station
Travel & Places|🚊|1.0|tram
Travel & Places|🚝|1.0|monorail
Travel & Places|🚞|1.0|mountain railway
Travel & Places|🚋|1.0|tram car
Travel & Places|🚌|0.6|bus
Travel & Places|🚍|0.7|oncoming bus
Travel & Places|🚎|1.0|trolleybus
Travel & Places|🚐|1.0|minibus
Travel & Places|🚑|0.6|ambulance
Travel & Places|🚒|0.6|fire engine
Travel & Places|🚓|0.6|police car
Travel & Places|🚔|0.7|oncoming police car
Travel & Places|🚕|0.6|taxi
Travel & Places|🚖|1.0|oncoming taxi
Travel & Places|🚗|0.6|automobile
Travel & Places|🚘|0.7|oncoming automobile
Travel & Places|🚙|0.6|sport utility vehicle
Travel & Places|🛻|13.0|pickup truck
Travel & Places|🚚|0.6|delivery truck
Travel & Places|🚛|1.0|articulated lorry
Travel & Places|🚜|1.0|tractor
Travel & Places|🏎️|0.7|racing car
Travel & Places|🏍️|0.7|motorcycle
Travel & Places|🛵|3.0|motor scooter
Travel & Places|🦽|12.0|manual wheelchair
Travel & Places|🦼|12.0|motorized wheelchair
Travel & Places|🛺|12.0|auto rickshaw
Travel & Places|🚲|0.6|bicycle
Travel & Places|🛴|3.0|kick scooter
Travel & Places|🛹|11.0|skateboard
Travel & Places|🛼|13.0|roller skate
Travel & Places|🚏|0.6|bus stop
Travel & Places|🛣️|0.7|motorway
Travel & Places|🛤️|0.7|railway track
Travel & Places|🛢️|0.7|oil drum
Travel & Places|⛽|0.6|fuel pump
Travel & Places|🛞|14.0|wheel
Travel & Places|🚨|0.6|police car light
Travel & Places|🚥|0.6|horizontal traffic light
Travel & Places|🚦|1.0|vertical traffic light
Travel & Places|🛑|3.0|stop sign
Travel & Places|🚧|0.6|construction
Travel & Places|🛙|18.0|lighthouse
Travel & Places|⚓|0.6|anchor
Travel & Places|🛟|14.0|ring buoy
Travel & Places|⛵|0.6|sailboat
Travel & Places|🛶|3.0|canoe
Travel & Places|🚤|0.6|speedboat
Travel & Places|🛳️|0.7|passenger ship
Travel & Places|⛴️|0.7|ferry
Travel & Places|🛥️|0.7|motor boat
Travel & Places|🚢|0.6|ship
Travel & Places|✈️|0.6|airplane
Travel & Places|🛩️|0.7|small airplane
Travel & Places|🛫|1.0|airplane departure
Travel & Places|🛬|1.0|airplane arrival
Travel & Places|🪂|12.0|parachute
Travel & Places|💺|0.6|seat
Travel & Places|🚁|1.0|helicopter
Travel & Places|🚟|1.0|suspension railway
Travel & Places|🚠|1.0|mountain cableway
Travel & Places|🚡|1.0|aerial tramway
Travel & Places|🛰️|0.7|satellite
Travel & Places|🚀|0.6|rocket
Travel & Places|🛸|5.0|flying saucer
Travel & Places|🛎️|0.7|bellhop bell
Travel & Places|🧳|11.0|luggage
Travel & Places|⌛|0.6|hourglass done
Travel & Places|⏳|0.6|hourglass not done
Travel & Places|⌚|0.6|watch
Travel & Places|⏰|0.6|alarm clock
Travel & Places|⏱️|1.0|stopwatch
Travel & Places|⏲️|1.0|timer clock
Travel & Places|🕰️|0.7|mantelpiece clock
Travel & Places|🕛|0.6|twelve o’clock
Travel & Places|🕧|0.7|twelve-thirty
Travel & Places|🕐|0.6|one o’clock
Travel & Places|🕜|0.7|one-thirty
Travel & Places|🕑|0.6|two o’clock
Travel & Places|🕝|0.7|two-thirty
Travel & Places|🕒|0.6|three o’clock
Travel & Places|🕞|0.7|three-thirty
Travel & Places|🕓|0.6|four o’clock
Travel & Places|🕟|0.7|four-thirty
Travel & Places|🕔|0.6|five o’clock
Travel & Places|🕠|0.7|five-thirty
Travel & Places|🕕|0.6|six o’clock
Travel & Places|🕡|0.7|six-thirty
Travel & Places|🕖|0.6|seven o’clock
Travel & Places|🕢|0.7|seven-thirty
Travel & Places|🕗|0.6|eight o’clock
Travel & Places|🕣|0.7|eight-thirty
Travel & Places|🕘|0.6|nine o’clock
Travel & Places|🕤|0.7|nine-thirty
Travel & Places|🕙|0.6|ten o’clock
Travel & Places|🕥|0.7|ten-thirty
Travel & Places|🕚|0.6|eleven o’clock
Travel & Places|🕦|0.7|eleven-thirty
Travel & Places|🌑|0.6|new moon
Travel & Places|🌒|1.0|waxing crescent moon
Travel & Places|🌓|0.6|first quarter moon
Travel & Places|🌔|0.6|waxing gibbous moon
Travel & Places|🌕|0.6|full moon
Travel & Places|🌖|1.0|waning gibbous moon
Travel & Places|🌗|1.0|last quarter moon
Travel & Places|🌘|1.0|waning crescent moon
Travel & Places|🌙|0.6|crescent moon
Travel & Places|🌚|1.0|new moon face
Travel & Places|🌛|0.6|first quarter moon face
Travel & Places|🌜|0.7|last quarter moon face
Travel & Places|🌡️|0.7|thermometer
Travel & Places|☀️|0.6|sun
Travel & Places|🌝|1.0|full moon face
Travel & Places|🌞|1.0|sun with face
Travel & Places|🪐|12.0|ringed planet
Travel & Places|⭐|0.6|star
Travel & Places|🌟|0.6|glowing star
Travel & Places|🌠|0.6|shooting star
Travel & Places|🌌|0.6|milky way
Travel & Places|☁️|0.6|cloud
Travel & Places|⛅|0.6|sun behind cloud
Travel & Places|⛈️|0.7|cloud with lightning and rain
Travel & Places|🌤️|0.7|sun behind small cloud
Travel & Places|🌥️|0.7|sun behind large cloud
Travel & Places|🌦️|0.7|sun behind rain cloud
Travel & Places|🌧️|0.7|cloud with rain
Travel & Places|🌨️|0.7|cloud with snow
Travel & Places|🌩️|0.7|cloud with lightning
Travel & Places|🌪️|0.7|tornado
Travel & Places|🌫️|0.7|fog
Travel & Places|🌬️|0.7|wind face
Travel & Places|🌀|0.6|cyclone
Travel & Places|🌈|0.6|rainbow
Travel & Places|🌂|0.6|closed umbrella
Travel & Places|☂️|0.7|umbrella
Travel & Places|☔|0.6|umbrella with rain drops
Travel & Places|⛱️|0.7|umbrella on ground
Travel & Places|⚡|0.6|high voltage
Travel & Places|❄️|0.6|snowflake
Travel & Places|☃️|0.7|snowman
Travel & Places|⛄|0.6|snowman without snow
Travel & Places|☄️|1.0|comet
Travel & Places|🪋|18.0|meteor
Travel & Places|🔥|0.6|fire
Travel & Places|💧|0.6|droplet
Travel & Places|🌊|0.6|water wave
Activities|🎃|0.6|jack-o-lantern
Activities|🎄|0.6|Christmas tree
Activities|🎆|0.6|fireworks
Activities|🎇|0.6|sparkler
Activities|🧨|11.0|firecracker
Activities|✨|0.6|sparkles
Activities|🎈|0.6|balloon
Activities|🎉|0.6|party popper
Activities|🎊|0.6|confetti ball
Activities|🎋|0.6|tanabata tree
Activities|🎍|0.6|pine decoration
Activities|🎎|0.6|Japanese dolls
Activities|🎏|0.6|carp streamer
Activities|🎐|0.6|wind chime
Activities|🎑|0.6|moon viewing ceremony
Activities|🧧|11.0|red envelope
Activities|🎀|0.6|ribbon
Activities|🎁|0.6|wrapped gift
Activities|🎗️|0.7|reminder ribbon
Activities|🎟️|0.7|admission tickets
Activities|🎫|0.6|ticket
Activities|🎖️|0.7|military medal
Activities|🏆|0.6|trophy
Activities|🏅|1.0|sports medal
Activities|🥇|3.0|1st place medal
Activities|🥈|3.0|2nd place medal
Activities|🥉|3.0|3rd place medal
Activities|⚽|0.6|soccer ball
Activities|⚾|0.6|baseball
Activities|🥎|11.0|softball
Activities|🏀|0.6|basketball
Activities|🏐|1.0|volleyball
Activities|🏈|0.6|american football
Activities|🏉|1.0|rugby football
Activities|🎾|0.6|tennis
Activities|🥏|11.0|flying disc
Activities|🎳|0.6|bowling
Activities|🏏|1.0|cricket game
Activities|🏑|1.0|field hockey
Activities|🏒|1.0|ice hockey
Activities|🥍|11.0|lacrosse
Activities|🏓|1.0|ping pong
Activities|🏸|1.0|badminton
Activities|🥊|3.0|boxing glove
Activities|🥋|3.0|martial arts uniform
Activities|🥅|3.0|goal net
Activities|⛳|0.6|flag in hole
Activities|⛸️|0.7|ice skate
Activities|🎣|0.6|fishing pole
Activities|🤿|12.0|diving mask
Activities|🎽|0.6|running shirt
Activities|🎿|0.6|skis
Activities|🛷|5.0|sled
Activities|🥌|5.0|curling stone
Activities|🎯|0.6|bullseye
Activities|🪀|12.0|yo-yo
Activities|🪁|12.0|kite
Activities|🔫|0.6|water pistol
Activities|🎱|0.6|pool 8 ball
Activities|🔮|0.6|crystal ball
Activities|🪄|13.0|magic wand
Activities|🎮|0.6|video game
Activities|🕹️|0.7|joystick
Activities|🎰|0.6|slot machine
Activities|🎲|0.6|game die
Activities|🧩|11.0|puzzle piece
Activities|🧸|11.0|teddy bear
Activities|🪅|13.0|piñata
Activities|🪩|14.0|mirror ball
Activities|🪆|13.0|nesting dolls
Activities|♠️|0.6|spade suit
Activities|♥️|0.6|heart suit
Activities|♦️|0.6|diamond suit
Activities|♣️|0.6|club suit
Activities|♟️|11.0|chess pawn
Activities|🃏|0.6|joker
Activities|🀄|0.6|mahjong red dragon
Activities|🎴|0.6|flower playing cards
Activities|🎭|0.6|performing arts
Activities|🖼️|0.7|framed picture
Activities|🎨|0.6|artist palette
Activities|🧵|11.0|thread
Activities|🪡|13.0|sewing needle
Activities|🧶|11.0|yarn
Activities|🪢|13.0|knot
Objects|👓|0.6|glasses
Objects|🕶️|0.7|sunglasses
Objects|🥽|11.0|goggles
Objects|🥼|11.0|lab coat
Objects|🦺|12.0|safety vest
Objects|👔|0.6|necktie
Objects|👕|0.6|t-shirt
Objects|👖|0.6|jeans
Objects|🧣|5.0|scarf
Objects|🧤|5.0|gloves
Objects|🧥|5.0|coat
Objects|🧦|5.0|socks
Objects|👗|0.6|dress
Objects|👘|0.6|kimono
Objects|🥻|12.0|sari
Objects|🩱|12.0|one-piece swimsuit
Objects|🩲|12.0|briefs
Objects|🩳|12.0|shorts
Objects|👙|0.6|bikini
Objects|👚|0.6|woman’s clothes
Objects|🪭|15.0|folding hand fan
Objects|👛|0.6|purse
Objects|👜|0.6|handbag
Objects|👝|0.6|clutch bag
Objects|🛍️|0.7|shopping bags
Objects|🎒|0.6|backpack
Objects|🩴|13.0|thong sandal
Objects|👞|0.6|man’s shoe
Objects|👟|0.6|running shoe
Objects|🥾|11.0|hiking boot
Objects|🥿|11.0|flat shoe
Objects|👠|0.6|high-heeled shoe
Objects|👡|0.6|woman’s sandal
Objects|🩰|12.0|ballet shoes
Objects|👢|0.6|woman’s boot
Objects|🪮|15.0|hair pick
Objects|👑|0.6|crown
Objects|👒|0.6|woman’s hat
Objects|🎩|0.6|top hat
Objects|🎓|0.6|graduation cap
Objects|🧢|5.0|billed cap
Objects|🪖|13.0|military helmet
Objects|⛑️|0.7|rescue worker’s helmet
Objects|📿|1.0|prayer beads
Objects|💄|0.6|lipstick
Objects|💍|0.6|ring
Objects|💎|0.6|gem stone
Objects|🔇|1.0|muted speaker
Objects|🔈|0.7|speaker low volume
Objects|🔉|1.0|speaker medium volume
Objects|🔊|0.6|speaker high volume
Objects|📢|0.6|loudspeaker
Objects|📣|0.6|megaphone
Objects|📯|1.0|postal horn
Objects|🔔|0.6|bell
Objects|🔕|1.0|bell with slash
Objects|🎼|0.6|musical score
Objects|🎵|0.6|musical note
Objects|🎶|0.6|musical notes
Objects|🎙️|0.7|studio microphone
Objects|🎚️|0.7|level slider
Objects|🎛️|0.7|control knobs
Objects|🎤|0.6|microphone
Objects|🎧|0.6|headphone
Objects|📻|0.6|radio
Objects|🎷|0.6|saxophone
Objects|🎺|0.6|trumpet
Objects|🪊|17.0|trombone
Objects|🪗|13.0|accordion
Objects|🎸|0.6|guitar
Objects|🎹|0.6|musical keyboard
Objects|🎻|0.6|violin
Objects|🪕|12.0|banjo
Objects|🥁|3.0|drum
Objects|🪘|13.0|long drum
Objects|🪇|15.0|maracas
Objects|🪈|15.0|flute
Objects|🪉|16.0|harp
Objects|📱|0.6|mobile phone
Objects|📲|0.6|mobile phone with arrow
Objects|☎️|0.6|telephone
Objects|📞|0.6|telephone receiver
Objects|📟|0.6|pager
Objects|📠|0.6|fax machine
Objects|🔋|0.6|battery
Objects|🪫|14.0|low battery
Objects|🔌|0.6|electric plug
Objects|💻|0.6|laptop
Objects|🖥️|0.7|desktop computer
Objects|🖨️|0.7|printer
Objects|⌨️|1.0|keyboard
Objects|🖱️|0.7|computer mouse
Objects|🖲️|0.7|trackball
Objects|💽|0.6|computer disk
Objects|💾|0.6|floppy disk
Objects|💿|0.6|optical disk
Objects|📀|0.6|dvd
Objects|🧮|11.0|abacus
Objects|🎥|0.6|movie camera
Objects|🎞️|0.7|film frames
Objects|📽️|0.7|film projector
Objects|🎬|0.6|clapper board
Objects|📺|0.6|television
Objects|📷|0.6|camera
Objects|📸|1.0|camera with flash
Objects|📹|0.6|video camera
Objects|📼|0.6|videocassette
Objects|🔍|0.6|magnifying glass tilted left
Objects|🔎|0.6|magnifying glass tilted right
Objects|🕯️|0.7|candle
Objects|💡|0.6|light bulb
Objects|🔦|0.6|flashlight
Objects|🏮|0.6|red paper lantern
Objects|🪔|12.0|diya lamp
Objects|📔|0.6|notebook with decorative cover
Objects|📕|0.6|closed book
Objects|📖|0.6|open book
Objects|📗|0.6|green book
Objects|📘|0.6|blue book
Objects|📙|0.6|orange book
Objects|📚|0.6|books
Objects|📓|0.6|notebook
Objects|📒|0.6|ledger
Objects|📃|0.6|page with curl
Objects|📜|0.6|scroll
Objects|📄|0.6|page facing up
Objects|📰|0.6|newspaper
Objects|🗞️|0.7|rolled-up newspaper
Objects|📑|0.6|bookmark tabs
Objects|🔖|0.6|bookmark
Objects|🏷️|0.7|label
Objects|🪙|13.0|coin
Objects|💰|0.6|money bag
Objects|🪎|17.0|treasure chest
Objects|💴|0.6|yen banknote
Objects|💵|0.6|dollar banknote
Objects|💶|1.0|euro banknote
Objects|💷|1.0|pound banknote
Objects|💸|0.6|money with wings
Objects|💳|0.6|credit card
Objects|🧾|11.0|receipt
Objects|💹|0.6|chart increasing with yen
Objects|✉️|0.6|envelope
Objects|📧|0.6|e-mail
Objects|📨|0.6|incoming envelope
Objects|📩|0.6|envelope with arrow
Objects|📤|0.6|outbox tray
Objects|📥|0.6|inbox tray
Objects|📦|0.6|package
Objects|📫|0.6|closed mailbox with raised flag
Objects|📪|0.6|closed mailbox with lowered flag
Objects|📬|0.7|open mailbox with raised flag
Objects|📭|0.7|open mailbox with lowered flag
Objects|📮|0.6|postbox
Objects|🗳️|0.7|ballot box with ballot
Objects|✏️|0.6|pencil
Objects|✒️|0.6|black nib
Objects|🖋️|0.7|fountain pen
Objects|🖊️|0.7|pen
Objects|🖌️|0.7|paintbrush
Objects|🖍️|0.7|crayon
Objects|📝|0.6|memo
Objects|🪌|18.0|eraser
Objects|💼|0.6|briefcase
Objects|📁|0.6|file folder
Objects|📂|0.6|open file folder
Objects|🗂️|0.7|card index dividers
Objects|📅|0.6|calendar
Objects|📆|0.6|tear-off calendar
Objects|🗒️|0.7|spiral notepad
Objects|🗓️|0.7|spiral calendar
Objects|📇|0.6|card index
Objects|📈|0.6|chart increasing
Objects|📉|0.6|chart decreasing
Objects|📊|0.6|bar chart
Objects|📋|0.6|clipboard
Objects|📌|0.6|pushpin
Objects|📍|0.6|round pushpin
Objects|📎|0.6|paperclip
Objects|🖇️|0.7|linked paperclips
Objects|📏|0.6|straight ruler
Objects|📐|0.6|triangular ruler
Objects|✂️|0.6|scissors
Objects|🗃️|0.7|card file box
Objects|🗄️|0.7|file cabinet
Objects|🗑️|0.7|wastebasket
Objects|🔒|0.6|locked
Objects|🔓|0.6|unlocked
Objects|🔏|0.6|locked with pen
Objects|🔐|0.6|locked with key
Objects|🔑|0.6|key
Objects|🗝️|0.7|old key
Objects|🪍|18.0|net with handle
Objects|🔨|0.6|hammer
Objects|🪓|12.0|axe
Objects|⛏️|0.7|pick
Objects|⚒️|1.0|hammer and pick
Objects|🛠️|0.7|hammer and wrench
Objects|🗡️|0.7|dagger
Objects|⚔️|1.0|crossed swords
Objects|💣|0.6|bomb
Objects|🪃|13.0|boomerang
Objects|🏹|1.0|bow and arrow
Objects|🛡️|0.7|shield
Objects|🪚|13.0|carpentry saw
Objects|🔧|0.6|wrench
Objects|🪛|13.0|screwdriver
Objects|🔩|0.6|nut and bolt
Objects|⚙️|1.0|gear
Objects|🗜️|0.7|clamp
Objects|⚖️|1.0|balance scale
Objects|🦯|12.0|white cane
Objects|🔗|0.6|link
Objects|⛓️‍💥|15.1|broken chain
Objects|⛓️|0.7|chains
Objects|🪝|13.0|hook
Objects|🧰|11.0|toolbox
Objects|🧲|11.0|magnet
Objects|🪜|13.0|ladder
Objects|🪏|16.0|shovel
Objects|⚗️|1.0|alembic
Objects|🧪|11.0|test tube
Objects|🧫|11.0|petri dish
Objects|🧬|11.0|dna
Objects|🔬|1.0|microscope
Objects|🔭|1.0|telescope
Objects|📡|0.6|satellite antenna
Objects|💉|0.6|syringe
Objects|🩸|12.0|drop of blood
Objects|💊|0.6|pill
Objects|🩹|12.0|adhesive bandage
Objects|🩼|14.0|crutch
Objects|🩺|12.0|stethoscope
Objects|🩻|14.0|x-ray
Objects|🚪|0.6|door
Objects|🛗|13.0|elevator
Objects|🪞|13.0|mirror
Objects|🪟|13.0|window
Objects|🛏️|0.7|bed
Objects|🛋️|0.7|couch and lamp
Objects|🪑|12.0|chair
Objects|🚽|0.6|toilet
Objects|🪠|13.0|plunger
Objects|🚿|1.0|shower
Objects|🛁|1.0|bathtub
Objects|🪤|13.0|mouse trap
Objects|🪒|12.0|razor
Objects|🧴|11.0|lotion bottle
Objects|🧷|11.0|safety pin
Objects|🧹|11.0|broom
Objects|🧺|11.0|basket
Objects|🧻|11.0|roll of paper
Objects|🪣|13.0|bucket
Objects|🧼|11.0|soap
Objects|🫧|14.0|bubbles
Objects|🪥|13.0|toothbrush
Objects|🧽|11.0|sponge
Objects|🧯|11.0|fire extinguisher
Objects|🛒|3.0|shopping cart
Objects|🚬|0.6|cigarette
Objects|⚰️|1.0|coffin
Objects|🪦|13.0|headstone
Objects|⚱️|1.0|funeral urn
Objects|🧿|11.0|nazar amulet
Objects|🪬|14.0|hamsa
Objects|🗿|0.6|moai
Objects|🪧|13.0|placard
Objects|🪪|14.0|identification card
Symbols|🏧|0.6|ATM sign
Symbols|🚮|1.0|litter in bin sign
Symbols|🚰|1.0|potable water
Symbols|♿|0.6|wheelchair symbol
Symbols|🚹|0.6|men’s room
Symbols|🚺|0.6|women’s room
Symbols|🚻|0.6|restroom
Symbols|🚼|0.6|baby symbol
Symbols|🚾|0.6|water closet
Symbols|🛂|1.0|passport control
Symbols|🛃|1.0|customs
Symbols|🛄|1.0|baggage claim
Symbols|🛅|1.0|left luggage
Symbols|⚠️|0.6|warning
Symbols|🚸|1.0|children crossing
Symbols|⛔|0.6|no entry
Symbols|🚫|0.6|prohibited
Symbols|🚳|1.0|no bicycles
Symbols|🚭|0.6|no smoking
Symbols|🚯|1.0|no littering
Symbols|🚱|1.0|non-potable water
Symbols|🚷|1.0|no pedestrians
Symbols|📵|1.0|no mobile phones
Symbols|🔞|0.6|no one under eighteen
Symbols|☢️|1.0|radioactive
Symbols|☣️|1.0|biohazard
Symbols|⬆️|0.6|up arrow
Symbols|↗️|0.6|up-right arrow
Symbols|➡️|0.6|right arrow
Symbols|↘️|0.6|down-right arrow
Symbols|⬇️|0.6|down arrow
Symbols|↙️|0.6|down-left arrow
Symbols|⬅️|0.6|left arrow
Symbols|↖️|0.6|up-left arrow
Symbols|↕️|0.6|up-down arrow
Symbols|↔️|0.6|left-right arrow
Symbols|↩️|0.6|right arrow curving left
Symbols|↪️|0.6|left arrow curving right
Symbols|⤴️|0.6|right arrow curving up
Symbols|⤵️|0.6|right arrow curving down
Symbols|🔃|0.6|clockwise vertical arrows
Symbols|🔄|1.0|counterclockwise arrows button
Symbols|🔙|0.6|BACK arrow
Symbols|🔚|0.6|END arrow
Symbols|🔛|0.6|ON! arrow
Symbols|🔜|0.6|SOON arrow
Symbols|🔝|0.6|TOP arrow
Symbols|🛐|1.0|place of worship
Symbols|⚛️|1.0|atom symbol
Symbols|🕉️|0.7|om
Symbols|✡️|0.7|star of David
Symbols|☸️|0.7|wheel of dharma
Symbols|☯️|0.7|yin yang
Symbols|✝️|0.7|latin cross
Symbols|☦️|1.0|orthodox cross
Symbols|☪️|0.7|star and crescent
Symbols|☮️|1.0|peace symbol
Symbols|🕎|1.0|menorah
Symbols|🔯|0.6|dotted six-pointed star
Symbols|🪯|15.0|khanda
Symbols|♈|0.6|Aries
Symbols|♉|0.6|Taurus
Symbols|♊|0.6|Gemini
Symbols|♋|0.6|Cancer
Symbols|♌|0.6|Leo
Symbols|♍|0.6|Virgo
Symbols|♎|0.6|Libra
Symbols|♏|0.6|Scorpio
Symbols|♐|0.6|Sagittarius
Symbols|♑|0.6|Capricorn
Symbols|♒|0.6|Aquarius
Symbols|♓|0.6|Pisces
Symbols|⛎|0.6|Ophiuchus
Symbols|🔀|1.0|shuffle tracks button
Symbols|🔁|1.0|repeat button
Symbols|🔂|1.0|repeat single button
Symbols|▶️|0.6|play button
Symbols|⏩|0.6|fast-forward button
Symbols|⏭️|0.7|next track button
Symbols|⏯️|1.0|play or pause button
Symbols|◀️|0.6|reverse button
Symbols|⏪|0.6|fast reverse button
Symbols|⏮️|0.7|last track button
Symbols|🔼|0.6|upwards button
Symbols|⏫|0.6|fast up button
Symbols|🔽|0.6|downwards button
Symbols|⏬|0.6|fast down button
Symbols|⏸️|0.7|pause button
Symbols|⏹️|0.7|stop button
Symbols|⏺️|0.7|record button
Symbols|⏏️|1.0|eject button
Symbols|🎦|0.6|cinema
Symbols|🔅|1.0|dim button
Symbols|🔆|1.0|bright button
Symbols|📶|0.6|antenna bars
Symbols|🛜|15.0|wireless
Symbols|📳|0.6|vibration mode
Symbols|📴|0.6|mobile phone off
Symbols|♀️|4.0|female sign
Symbols|♂️|4.0|male sign
Symbols|⚧️|13.0|transgender symbol
Symbols|✖️|0.6|multiply
Symbols|➕|0.6|plus
Symbols|➖|0.6|minus
Symbols|➗|0.6|divide
Symbols|🟰|14.0|heavy equals sign
Symbols|♾️|11.0|infinity
Symbols|‼️|0.6|double exclamation mark
Symbols|⁉️|0.6|exclamation question mark
Symbols|❓|0.6|red question mark
Symbols|❔|0.6|white question mark
Symbols|❕|0.6|white exclamation mark
Symbols|❗|0.6|red exclamation mark
Symbols|〰️|0.6|wavy dash
Symbols|💱|0.6|currency exchange
Symbols|💲|0.6|heavy dollar sign
Symbols|⚕️|4.0|medical symbol
Symbols|♻️|0.6|recycling symbol
Symbols|⚜️|1.0|fleur-de-lis
Symbols|🔱|0.6|trident emblem
Symbols|📛|0.6|name badge
Symbols|🔰|0.6|Japanese symbol for beginner
Symbols|⭕|0.6|hollow red circle
Symbols|✅|0.6|check mark button
Symbols|☑️|0.6|check box with check
Symbols|✔️|0.6|check mark
Symbols|❌|0.6|cross mark
Symbols|❎|0.6|cross mark button
Symbols|➰|0.6|curly loop
Symbols|➿|1.0|double curly loop
Symbols|〽️|0.6|part alternation mark
Symbols|✳️|0.6|eight-spoked asterisk
Symbols|✴️|0.6|eight-pointed star
Symbols|❇️|0.6|sparkle
Symbols|©️|0.6|copyright
Symbols|®️|0.6|registered
Symbols|™️|0.6|trade mark
Symbols|🫟|16.0|splatter
Symbols|#️⃣|0.6|keycap: #
Symbols|*️⃣|2.0|keycap: *
Symbols|0️⃣|0.6|keycap: 0
Symbols|1️⃣|0.6|keycap: 1
Symbols|2️⃣|0.6|keycap: 2
Symbols|3️⃣|0.6|keycap: 3
Symbols|4️⃣|0.6|keycap: 4
Symbols|5️⃣|0.6|keycap: 5
Symbols|6️⃣|0.6|keycap: 6
Symbols|7️⃣|0.6|keycap: 7
Symbols|8️⃣|0.6|keycap: 8
Symbols|9️⃣|0.6|keycap: 9
Symbols|🔟|0.6|keycap: 10
Symbols|🔠|0.6|input latin uppercase
Symbols|🔡|0.6|input latin lowercase
Symbols|🔢|0.6|input numbers
Symbols|🔣|0.6|input symbols
Symbols|🔤|0.6|input latin letters
Symbols|🅰️|0.6|A button (blood type)
Symbols|🆎|0.6|AB button (blood type)
Symbols|🅱️|0.6|B button (blood type)
Symbols|🆑|0.6|CL button
Symbols|🆒|0.6|COOL button
Symbols|🆓|0.6|FREE button
Symbols|ℹ️|0.6|information
Symbols|🆔|0.6|ID button
Symbols|Ⓜ️|0.6|circled M
Symbols|🆕|0.6|NEW button
Symbols|🆖|0.6|NG button
Symbols|🅾️|0.6|O button (blood type)
Symbols|🆗|0.6|OK button
Symbols|🅿️|0.6|P button
Symbols|🆘|0.6|SOS button
Symbols|🆙|0.6|UP! button
Symbols|🆚|0.6|VS button
Symbols|🈁|0.6|Japanese “here” button
Symbols|🈂️|0.6|Japanese “service charge” button
Symbols|🈷️|0.6|Japanese “monthly amount” button
Symbols|🈶|0.6|Japanese “not free of charge” button
Symbols|🈯|0.6|Japanese “reserved” button
Symbols|🉐|0.6|Japanese “bargain” button
Symbols|🈹|0.6|Japanese “discount” button
Symbols|🈚|0.6|Japanese “free of charge” button
Symbols|🈲|0.6|Japanese “prohibited” button
Symbols|🉑|0.6|Japanese “acceptable” button
Symbols|🈸|0.6|Japanese “application” button
Symbols|🈴|0.6|Japanese “passing grade” button
Symbols|🈳|0.6|Japanese “vacancy” button
Symbols|㊗️|0.6|Japanese “congratulations” button
Symbols|㊙️|0.6|Japanese “secret” button
Symbols|🈺|0.6|Japanese “open for business” button
Symbols|🈵|0.6|Japanese “no vacancy” button
Symbols|🔴|0.6|red circle
Symbols|🟠|12.0|orange circle
Symbols|🟡|12.0|yellow circle
Symbols|🟢|12.0|green circle
Symbols|🔵|0.6|blue circle
Symbols|🟣|12.0|purple circle
Symbols|🟤|12.0|brown circle
Symbols|⚫|0.6|black circle
Symbols|⚪|0.6|white circle
Symbols|🟥|12.0|red square
Symbols|🟧|12.0|orange square
Symbols|🟨|12.0|yellow square
Symbols|🟩|12.0|green square
Symbols|🟦|12.0|blue square
Symbols|🟪|12.0|purple square
Symbols|🟫|12.0|brown square
Symbols|⬛|0.6|black large square
Symbols|⬜|0.6|white large square
Symbols|◼️|0.6|black medium square
Symbols|◻️|0.6|white medium square
Symbols|◾|0.6|black medium-small square
Symbols|◽|0.6|white medium-small square
Symbols|▪️|0.6|black small square
Symbols|▫️|0.6|white small square
Symbols|🔶|0.6|large orange diamond
Symbols|🔷|0.6|large blue diamond
Symbols|🔸|0.6|small orange diamond
Symbols|🔹|0.6|small blue diamond
Symbols|🔺|0.6|red triangle pointed up
Symbols|🔻|0.6|red triangle pointed down
Symbols|💠|0.6|diamond with a dot
Symbols|🔘|0.6|radio button
Symbols|🔳|0.6|white square button
Symbols|🔲|0.6|black square button
Flags|🏁|0.6|chequered flag
Flags|🚩|0.6|triangular flag
Flags|🎌|0.6|crossed flags
Flags|🏴|1.0|black flag
Flags|🏳️|0.7|white flag
Flags|🏳️‍🌈|4.0|rainbow flag
Flags|🏳️‍⚧️|13.0|transgender flag
Flags|🏴‍☠️|11.0|pirate flag
Flags|🇦🇨|2.0|flag: Ascension Island
Flags|🇦🇩|2.0|flag: Andorra
Flags|🇦🇪|2.0|flag: United Arab Emirates
Flags|🇦🇫|2.0|flag: Afghanistan
Flags|🇦🇬|2.0|flag: Antigua & Barbuda
Flags|🇦🇮|2.0|flag: Anguilla
Flags|🇦🇱|2.0|flag: Albania
Flags|🇦🇲|2.0|flag: Armenia
Flags|🇦🇴|2.0|flag: Angola
Flags|🇦🇶|2.0|flag: Antarctica
Flags|🇦🇷|2.0|flag: Argentina
Flags|🇦🇸|2.0|flag: American Samoa
Flags|🇦🇹|2.0|flag: Austria
Flags|🇦🇺|2.0|flag: Australia
Flags|🇦🇼|2.0|flag: Aruba
Flags|🇦🇽|2.0|flag: Åland Islands
Flags|🇦🇿|2.0|flag: Azerbaijan
Flags|🇧🇦|2.0|flag: Bosnia & Herzegovina
Flags|🇧🇧|2.0|flag: Barbados
Flags|🇧🇩|2.0|flag: Bangladesh
Flags|🇧🇪|2.0|flag: Belgium
Flags|🇧🇫|2.0|flag: Burkina Faso
Flags|🇧🇬|2.0|flag: Bulgaria
Flags|🇧🇭|2.0|flag: Bahrain
Flags|🇧🇮|2.0|flag: Burundi
Flags|🇧🇯|2.0|flag: Benin
Flags|🇧🇱|2.0|flag: St. Barthélemy
Flags|🇧🇲|2.0|flag: Bermuda
Flags|🇧🇳|2.0|flag: Brunei
Flags|🇧🇴|2.0|flag: Bolivia
Flags|🇧🇶|2.0|flag: Caribbean Netherlands
Flags|🇧🇷|2.0|flag: Brazil
Flags|🇧🇸|2.0|flag: Bahamas
Flags|🇧🇹|2.0|flag: Bhutan
Flags|🇧🇻|2.0|flag: Bouvet Island
Flags|🇧🇼|2.0|flag: Botswana
Flags|🇧🇾|2.0|flag: Belarus
Flags|🇧🇿|2.0|flag: Belize
Flags|🇨🇦|2.0|flag: Canada
Flags|🇨🇨|2.0|flag: Cocos (Keeling) Islands
Flags|🇨🇩|2.0|flag: Congo - Kinshasa
Flags|🇨🇫|2.0|flag: Central African Republic
Flags|🇨🇬|2.0|flag: Congo - Brazzaville
Flags|🇨🇭|2.0|flag: Switzerland
Flags|🇨🇮|2.0|flag: Côte d’Ivoire
Flags|🇨🇰|2.0|flag: Cook Islands
Flags|🇨🇱|2.0|flag: Chile
Flags|🇨🇲|2.0|flag: Cameroon
Flags|🇨🇳|0.6|flag: China
Flags|🇨🇴|2.0|flag: Colombia
Flags|🇨🇵|2.0|flag: Clipperton Island
Flags|🇨🇶|16.0|flag: Sark
Flags|🇨🇷|2.0|flag: Costa Rica
Flags|🇨🇺|2.0|flag: Cuba
Flags|🇨🇻|2.0|flag: Cape Verde
Flags|🇨🇼|2.0|flag: Curaçao
Flags|🇨🇽|2.0|flag: Christmas Island
Flags|🇨🇾|2.0|flag: Cyprus
Flags|🇨🇿|2.0|flag: Czechia
Flags|🇩🇪|0.6|flag: Germany
Flags|🇩🇬|2.0|flag: Diego Garcia
Flags|🇩🇯|2.0|flag: Djibouti
Flags|🇩🇰|2.0|flag: Denmark
Flags|🇩🇲|2.0|flag: Dominica
Flags|🇩🇴|2.0|flag: Dominican Republic
Flags|🇩🇿|2.0|flag: Algeria
Flags|🇪🇦|2.0|flag: Ceuta & Melilla
Flags|🇪🇨|2.0|flag: Ecuador
Flags|🇪🇪|2.0|flag: Estonia
Flags|🇪🇬|2.0|flag: Egypt
Flags|🇪🇭|2.0|flag: Western Sahara
Flags|🇪🇷|2.0|flag: Eritrea
Flags|🇪🇸|0.6|flag: Spain
Flags|🇪🇹|2.0|flag: Ethiopia
Flags|🇪🇺|2.0|flag: European Union
Flags|🇫🇮|2.0|flag: Finland
Flags|🇫🇯|2.0|flag: Fiji
Flags|🇫🇰|2.0|flag: Falkland Islands
Flags|🇫🇲|2.0|flag: Micronesia
Flags|🇫🇴|2.0|flag: Faroe Islands
Flags|🇫🇷|0.6|flag: France
Flags|🇬🇦|2.0|flag: Gabon
Flags|🇬🇧|0.6|flag: United Kingdom
Flags|🇬🇩|2.0|flag: Grenada
Flags|🇬🇪|2.0|flag: Georgia
Flags|🇬🇫|2.0|flag: French Guiana
Flags|🇬🇬|2.0|flag: Guernsey
Flags|🇬🇭|2.0|flag: Ghana
Flags|🇬🇮|2.0|flag: Gibraltar
Flags|🇬🇱|2.0|flag: Greenland
Flags|🇬🇲|2.0|flag: Gambia
Flags|🇬🇳|2.0|flag: Guinea
Flags|🇬🇵|2.0|flag: Guadeloupe
Flags|🇬🇶|2.0|flag: Equatorial Guinea
Flags|🇬🇷|2.0|flag: Greece
Flags|🇬🇸|2.0|flag: South Georgia & South Sandwich Islands
Flags|🇬🇹|2.0|flag: Guatemala
Flags|🇬🇺|2.0|flag: Guam
Flags|🇬🇼|2.0|flag: Guinea-Bissau
Flags|🇬🇾|2.0|flag: Guyana
Flags|🇭🇰|2.0|flag: Hong Kong SAR China
Flags|🇭🇲|2.0|flag: Heard Island & McDonald Islands
Flags|🇭🇳|2.0|flag: Honduras
Flags|🇭🇷|2.0|flag: Croatia
Flags|🇭🇹|2.0|flag: Haiti
Flags|🇭🇺|2.0|flag: Hungary
Flags|🇮🇨|2.0|flag: Canary Islands
Flags|🇮🇩|2.0|flag: Indonesia
Flags|🇮🇪|2.0|flag: Ireland
Flags|🇮🇱|2.0|flag: Israel
Flags|🇮🇲|2.0|flag: Isle of Man
Flags|🇮🇳|2.0|flag: India
Flags|🇮🇴|2.0|flag: British Indian Ocean Territory
Flags|🇮🇶|2.0|flag: Iraq
Flags|🇮🇷|2.0|flag: Iran
Flags|🇮🇸|2.0|flag: Iceland
Flags|🇮🇹|0.6|flag: Italy
Flags|🇯🇪|2.0|flag: Jersey
Flags|🇯🇲|2.0|flag: Jamaica
Flags|🇯🇴|2.0|flag: Jordan
Flags|🇯🇵|0.6|flag: Japan
Flags|🇰🇪|2.0|flag: Kenya
Flags|🇰🇬|2.0|flag: Kyrgyzstan
Flags|🇰🇭|2.0|flag: Cambodia
Flags|🇰🇮|2.0|flag: Kiribati
Flags|🇰🇲|2.0|flag: Comoros
Flags|🇰🇳|2.0|flag: St. Kitts & Nevis
Flags|🇰🇵|2.0|flag: North Korea
Flags|🇰🇷|0.6|flag: South Korea
Flags|🇰🇼|2.0|flag: Kuwait
Flags|🇰🇾|2.0|flag: Cayman Islands
Flags|🇰🇿|2.0|flag: Kazakhstan
Flags|🇱🇦|2.0|flag: Laos
Flags|🇱🇧|2.0|flag: Lebanon
Flags|🇱🇨|2.0|flag: St. Lucia
Flags|🇱🇮|2.0|flag: Liechtenstein
Flags|🇱🇰|2.0|flag: Sri Lanka
Flags|🇱🇷|2.0|flag: Liberia
Flags|🇱🇸|2.0|flag: Lesotho
Flags|🇱🇹|2.0|flag: Lithuania
Flags|🇱🇺|2.0|flag: Luxembourg
Flags|🇱🇻|2.0|flag: Latvia
Flags|🇱🇾|2.0|flag: Libya
Flags|🇲🇦|2.0|flag: Morocco
Flags|🇲🇨|2.0|flag: Monaco
Flags|🇲🇩|2.0|flag: Moldova
Flags|🇲🇪|2.0|flag: Montenegro
Flags|🇲🇫|2.0|flag: St. Martin
Flags|🇲🇬|2.0|flag: Madagascar
Flags|🇲🇭|2.0|flag: Marshall Islands
Flags|🇲🇰|2.0|flag: North Macedonia
Flags|🇲🇱|2.0|flag: Mali
Flags|🇲🇲|2.0|flag: Myanmar (Burma)
Flags|🇲🇳|2.0|flag: Mongolia
Flags|🇲🇴|2.0|flag: Macao SAR China
Flags|🇲🇵|2.0|flag: Northern Mariana Islands
Flags|🇲🇶|2.0|flag: Martinique
Flags|🇲🇷|2.0|flag: Mauritania
Flags|🇲🇸|2.0|flag: Montserrat
Flags|🇲🇹|2.0|flag: Malta
Flags|🇲🇺|2.0|flag: Mauritius
Flags|🇲🇻|2.0|flag: Maldives
Flags|🇲🇼|2.0|flag: Malawi
Flags|🇲🇽|2.0|flag: Mexico
Flags|🇲🇾|2.0|flag: Malaysia
Flags|🇲🇿|2.0|flag: Mozambique
Flags|🇳🇦|2.0|flag: Namibia
Flags|🇳🇨|2.0|flag: New Caledonia
Flags|🇳🇪|2.0|flag: Niger
Flags|🇳🇫|2.0|flag: Norfolk Island
Flags|🇳🇬|2.0|flag: Nigeria
Flags|🇳🇮|2.0|flag: Nicaragua
Flags|🇳🇱|2.0|flag: Netherlands
Flags|🇳🇴|2.0|flag: Norway
Flags|🇳🇵|2.0|flag: Nepal
Flags|🇳🇷|2.0|flag: Nauru
Flags|🇳🇺|2.0|flag: Niue
Flags|🇳🇿|2.0|flag: New Zealand
Flags|🇴🇲|2.0|flag: Oman
Flags|🇵🇦|2.0|flag: Panama
Flags|🇵🇪|2.0|flag: Peru
Flags|🇵🇫|2.0|flag: French Polynesia
Flags|🇵🇬|2.0|flag: Papua New Guinea
Flags|🇵🇭|2.0|flag: Philippines
Flags|🇵🇰|2.0|flag: Pakistan
Flags|🇵🇱|2.0|flag: Poland
Flags|🇵🇲|2.0|flag: St. Pierre & Miquelon
Flags|🇵🇳|2.0|flag: Pitcairn Islands
Flags|🇵🇷|2.0|flag: Puerto Rico
Flags|🇵🇸|2.0|flag: Palestinian Territories
Flags|🇵🇹|2.0|flag: Portugal
Flags|🇵🇼|2.0|flag: Palau
Flags|🇵🇾|2.0|flag: Paraguay
Flags|🇶🇦|2.0|flag: Qatar
Flags|🇷🇪|2.0|flag: Réunion
Flags|🇷🇴|2.0|flag: Romania
Flags|🇷🇸|2.0|flag: Serbia
Flags|🇷🇺|0.6|flag: Russia
Flags|🇷🇼|2.0|flag: Rwanda
Flags|🇸🇦|2.0|flag: Saudi Arabia
Flags|🇸🇧|2.0|flag: Solomon Islands
Flags|🇸🇨|2.0|flag: Seychelles
Flags|🇸🇩|2.0|flag: Sudan
Flags|🇸🇪|2.0|flag: Sweden
Flags|🇸🇬|2.0|flag: Singapore
Flags|🇸🇭|2.0|flag: St. Helena, Ascension & Tristan da Cunha
Flags|🇸🇮|2.0|flag: Slovenia
Flags|🇸🇯|2.0|flag: Svalbard & Jan Mayen
Flags|🇸🇰|2.0|flag: Slovakia
Flags|🇸🇱|2.0|flag: Sierra Leone
Flags|🇸🇲|2.0|flag: San Marino
Flags|🇸🇳|2.0|flag: Senegal
Flags|🇸🇴|2.0|flag: Somalia
Flags|🇸🇷|2.0|flag: Suriname
Flags|🇸🇸|2.0|flag: South Sudan
Flags|🇸🇹|2.0|flag: São Tomé & Príncipe
Flags|🇸🇻|2.0|flag: El Salvador
Flags|🇸🇽|2.0|flag: Sint Maarten
Flags|🇸🇾|2.0|flag: Syria
Flags|🇸🇿|2.0|flag: Eswatini
Flags|🇹🇦|2.0|flag: Tristan da Cunha
Flags|🇹🇨|2.0|flag: Turks & Caicos Islands
Flags|🇹🇩|2.0|flag: Chad
Flags|🇹🇫|2.0|flag: French Southern and Antarctic Lands
Flags|🇹🇬|2.0|flag: Togo
Flags|🇹🇭|2.0|flag: Thailand
Flags|🇹🇯|2.0|flag: Tajikistan
Flags|🇹🇰|2.0|flag: Tokelau
Flags|🇹🇱|2.0|flag: Timor-Leste
Flags|🇹🇲|2.0|flag: Turkmenistan
Flags|🇹🇳|2.0|flag: Tunisia
Flags|🇹🇴|2.0|flag: Tonga
Flags|🇹🇷|2.0|flag: Türkiye
Flags|🇹🇹|2.0|flag: Trinidad & Tobago
Flags|🇹🇻|2.0|flag: Tuvalu
Flags|🇹🇼|2.0|flag: Taiwan
Flags|🇹🇿|2.0|flag: Tanzania
Flags|🇺🇦|2.0|flag: Ukraine
Flags|🇺🇬|2.0|flag: Uganda
Flags|🇺🇲|2.0|flag: U.S. Outlying Islands
Flags|🇺🇳|4.0|flag: United Nations
Flags|🇺🇸|0.6|flag: United States
Flags|🇺🇾|2.0|flag: Uruguay
Flags|🇺🇿|2.0|flag: Uzbekistan
Flags|🇻🇦|2.0|flag: Vatican City
Flags|🇻🇨|2.0|flag: St. Vincent & Grenadines
Flags|🇻🇪|2.0|flag: Venezuela
Flags|🇻🇬|2.0|flag: British Virgin Islands
Flags|🇻🇮|2.0|flag: U.S. Virgin Islands
Flags|🇻🇳|2.0|flag: Vietnam
Flags|🇻🇺|2.0|flag: Vanuatu
Flags|🇼🇫|2.0|flag: Wallis & Futuna
Flags|🇼🇸|2.0|flag: Samoa
Flags|🇽🇰|2.0|flag: Kosovo
Flags|🇾🇪|2.0|flag: Yemen
Flags|🇾🇹|2.0|flag: Mayotte
Flags|🇿🇦|2.0|flag: South Africa
Flags|🇿🇲|2.0|flag: Zambia
Flags|🇿🇼|2.0|flag: Zimbabwe
Flags|🏴󠁧󠁢󠁥󠁮󠁧󠁿|5.0|flag: England
Flags|🏴󠁧󠁢󠁳󠁣󠁴󠁿|5.0|flag: Scotland
Flags|🏴󠁧󠁢󠁷󠁬󠁳󠁿|5.0|flag: Wales
"""
}
