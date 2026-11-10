# Star Bazaar: Russian glossary and style guide (ru)

Draft 1, 2026-11-04; section 1 rewritten 2026-11-09 (interface is Russian). For four translators. English master: story/voice.md (every rule there holds in Russian too). Scope: event texts (EV_, EV<nn>_, BE<nn>), chain texts (CH_), tutorial and warning texts (TUT_G1..G10 with their _WHY lines, TUT_GALAXY_*, TUT_G3_PICK, WARN_*), and the menu and screen texts: MENU_* (main menu, game menu, confirmations), SCR_* (title, tagline, preface), END_* (ending screens, stat labels, buttons) and EPI_* (epilogue lines). The rest of the interface stays English: BTN_*, LBL_*, NOT_*, TIP_*, HINT_*, EVT_*, GOOD_*, WORLD_*, SK_* skill windows, top bar, tooltips, and the mission board MB_*. MENU_SKILLS and MENU_GALAXY also stay English: they label the top bar and the side rail, which are interface. Do not translate those.

The Russian menu and screen captions are Russian (Продолжить, Новая игра, Главное меню, Выйти из игры), while tutorial lines name the buttons that are still English (Skills, Settings, Galaxy). Event and tutorial texts must name a button exactly as it is on screen.

## 1. Interface and names (policy of 2026-11-09, replaces the old "stays Latin" rule)

The interface is Russian too. Every on-screen name (buttons, labels, goods, workshops, panels, skills, tiers) has ONE Russian word, and every text that names it uses exactly that word. Only proper names stay Latin and are never inflected: the title and building name Star Bazaar, planets, systems and clusters, houses ({bot1} {bot2} {bot3}, Harrow Combine, Velvet Concord, Ostrel Syndicate), people, ship models (Skerrit, Voruun Hauler, Bulkhead, Dart, Tramp, Tessarine). Placeholder worlds: "Временная A..C", "Заглушка D..H" (planets "Временная A1").

| English | Russian |
|---|---|
| Buy / Sell (buttons) | Купить / Продать |
| Buy order / Sell order | заказ на покупку / заказ на продажу |
| Send to... | Отправить в... |
| Skills / Skill points / skill | Навыки / Очки навыков / навык |
| Galaxy / Settings / Statistics / Help | Галактика / Настройки / Статистика / Справка |
| Competitors (retired) / House weather | Погода домов |
| Company storage | Хранилище компании |
| Space Storage | Космохранилище |
| Storage Link | Связь хранилищ |
| Ship upkeep / Expenses | Содержание кораблей / Расходы |
| Buy price / Sell price / Trip cost | Цена покупки / Цена продажи / Стоимость рейса |
| Permit Charter / permit | Хартия допусков / допуск |
| Foundations (skill tab) / Foundations (Bazaar stage) | Основы / Фундамент |
| Military / Luxury / Minerals / Biotech | Вооружения / Роскошь / Минералы / Биотех (genitive after "рынок", "объём": вооружений, роскоши, минералов, биотеха) |
| Smelter / Atelier / Munitions Line / Culture Lab / Fabric | Плавильня / Ателье / Линия боеприпасов / Лаборатория культур / Фабрикатор |
| Null Core | Нулевое ядро |
| Energy, Food, Rivets, Munitions, Weapons | Энергия, Еда, Заклёпки, Боеприпасы, Оружие (other goods: see GOOD_*_NAME) |
| Flagship / Pathfinder (ship class) | Флагман / Следопыт (capital letter, like the English) |
| Bazaar (short) / Star Bazaar (name) | Базар / Star Bazaar (Latin, uninflected) |
| Hungry / Surplus / Restless / Needs | Голодает / Избыток / Беспокойство / Нужды |
| tier | ступень |
| Flood / Shortage / Congestion | Затоваривание / Дефицит / Затор |
| Boost / Dock and trade / Unload to storage | Ускорение / Причалить и торговать / Выгрузить в хранилище |
| Upgrade route / Make this a hub | Улучшить маршрут / Сделать узлом |
| Exploration / Mining intensity / Start reclaiming | Исследование / Интенсивность добычи / Начать восстановление |
| Skip tutorial / OK | Пропустить обучение / ОК |
| the Opening / Rush order | Открытие / Срочный заказ |

Fixed word choices: world=мир, trading post=торговый пост, hub=узел, lane=трасса, trip=рейс, hold=трюм, workshop=мастерская, permit=допуск, skill point=очко навыков, cycles as "циклов: {n}". Gig=подряд (never "заказ"); order=заказ. House (firm that sends weather)=дом (дом {bot}, дома {bot}, дому {bot}); rival (older texts, EPI_CAP_*, END_SWEPT)=соперник; never "компания {bot}" ("компания" is the player). Skill names quoted with ёлочки in running text ("Навык «Долгий обжиг» ..."). Goods in running text are lower case and decline ("скупали энергию"). Button names in tutorial lines are quoted: «Купить».

Notes. "credits" is translated (кредиты). strength and growth are no longer shown to players: house weather is "погода дома {bot}", "ляжет мягче / жёстче", "придёт позже / раньше", "придержана".

### How names sit in Russian sentences
- Latin proper names and every {placeholder} are never inflected. Use an apposition with a Russian head noun: "дом {bot3}", "на планете Voltara", "в системе Hollin Reach".
- Russian UI words inflect normally.
- Numbers come only from placeholders; {cash_in}/{cash_out} take "кредитов", {n} takes "единицы" or "циклов: {n}".
- {cut}, {cut_std} fill-ins: CH_CUT "придерживает следующую погоду" (after "дом {bot}"), CH_CUT_STD "следующая погода придержана".

## 2. Story terms, one Russian term each

| English | Russian | Gender | Usage example |
|---|---|---|---|
| the Commons | Община | f | Община считает всё, что у неё есть. |
| the Plan | План | m | План не возражает. |
| five-cycle plan | план на пять циклов (lower case) | m | Склад открыт до конца плана на пять циклов. |
| the Bureau | Бюро (indeclinable) | n | Бюро ответит в порядке очереди. |
| Common Ledger | Общая книга | f | В Общей книге вас нет, но вы есть. |
| common good | общее благо (lower case, straight face) | n | Ради общего блага бланк подписан дважды. |
| fellow hand (address between people) | напарник (voc. same as nom.) | m | Напарник, лампы внизу ещё горят. |
| quota | квота | f | Квота на этот цикл выполнена на бумаге. |
| committee | комиссия | f | Комиссия рассмотрит вопрос. |
| form | бланк | m | Заполните бланк в двух экземплярах. |
| stamp | печать | f | На бланке стоит печать. |
| ration | паёк | m | Паёк выдаётся по списку. |
| cycle | цикл | m | Цена держится несколько циклов. |
| credits | кредиты (only plural) | m pl | Вы получите {cash_in} кредитов. |
| the company (the player) | компания | f | Компания платит за стоянку. |
| the player address | вы (formal plural) | | Вы можете продать нижний уровень. |
| crew | экипаж (ship), бригада (mine, base) | m / f | Экипаж Cinderrest сообщает о неисправности. |
| hauler | грузовоз | m | Грузовоз стоит у причала. |
| rivals | соперники (never "конкуренты", never "боты") | m pl | Соперники теряют силу. |
| relief (rescue payment) | пособие | n | Бюро выдало пособие. |
| salvage (one-time payout) | вынужденная продажа | f | Груз ушёл на вынужденную продажу. |
| workshops: the Atelier, the Smelter, the Munitions Line, the Culture Lab | ателье, плавильня, оружейная линия, лаборатория культур (lower case in running text) | n, f, f, f | Ателье выпустило партию. |
| dead world | мёртвый мир | m | Cinderrest, мёртвый мир с рудной базой. |

Hold the same term for the same thing in every text. No synonyms (not "деньги" for кредиты, not "конкурент" for соперник, not "склад" for Company storage because that name stays Latin).

### Address, gender, tense
- Always "вы", formal plural. The company is "компания" (feminine) or "вы".
- Past tense plural is gender-neutral and allowed: "вы продали". Never a singular past form that shows gender ("продал", "продала") for the player.
- Prefer present, future, imperative plural ("нажмите"), infinitive and impersonal forms.
- People in the story (a dockhand, a quartermaster) may have a gender; give them none unless the English does.

## 3. Tone in Russian terms

- Dry, a little wry, a small company in a large indifferent sky. Understatement beats comment. About one line in four carries irony; the irony never hides what the player must know.
- The bureaucratic comedy is rendered as plain officialese used with a straight face: "Бюро ответит в порядке очереди", "бланк принят к рассмотрению", "комиссия не возражает". Passive and impersonal forms are the joke. A slow, polite office, never a threatening one.
- Short sentences, one idea each. Plain verbs: купить, продать, выучить, закрыть, открыть, запустить.
- Price effect in words first ("дороже", "дешевле", "платят меньше"), musing second.
- No slang, no jargon, no diminutives, no swearing, no jokes at the cost of clarity.
- No exclamation marks. No emoji. No question tags or rhetorical questions.
- Nothing that reads as Soviet or any real regime: do not use "товарищ", "пятилетка", "партия", "съезд", "трудящиеся", "слава", "вперёд", "на благо Родины", "ударный", "соцсоревнование", "ЦК", or slogans in any form. No real titles, names, parties or historic chants. Only the invented terms of section 2.
- The mood of the place: one odd sensory detail per story text at most (hulls that creak, ducts that hum, the dark outside the glass). Hint, do not show.
- Tutorial lines (TUT_*) carry none of the flavour: plain imperative, no wit. Only _WHY lines may be one step warmer, and even they stay plain.
- No verdict words in chain texts (the English list: good, bad, right, wrong, fair, unfair, safe, risky, bold, kind, cruel, open, closed, quiet, polite, late, long, short, small, big, plain, clean). Do not use their Russian equivalents to judge an option. A text never says what an option shows about the player. Size words keep the same ladder: "немного" (a little), "заметно" (clearly), "резко" (sharply, rivals only). Durations: "на несколько циклов" (a few cycles), "на какое-то время" (for a while), "до конца партии" (for the rest of the run).
- Effect lines keep the shape "Get: ... Cost: ... Rivals: ..." as "Получите: ... Цена: ... Соперники: ..." in that order, three sentences, same shape for both options. No "но", "однако", "зато".
- Option buttons are two verb phrases of nearly equal length (within 5 characters in English; within 7 in Russian).

## 4. Formatting

- Placeholders are kept byte-identical and in the same set as the English text: {bot1} {bot2} {bot3} {bot} {cash_out} {cash_in} {n} {cut} {cut_std} {market} {get} {cost} {rivals} {workshop} {share} {bots} and any other {name} in the source. No placeholder added, dropped, renamed, translated, spaced or inflected. Count them per text before submitting.
- The English has no digits. The translation has none either: no numerals, no "1-й", no "5". Write every number as a word, and only if the English has one (it should not; numbers come from placeholders).
- Quotes: «ёлочки» only. Nested quotes: „лапки“ inside. No straight quotes.
- Dash: the em dash with spaces, " — ", where Russian grammar needs it (predicate dash, apposition, a break). English avoids long dashes, so use it sparingly. Never a hyphen in place of a dash. Hyphens only inside words (по-прежнему, кто-то).
- Full stop at the end of every body, effect line, result and tutorial line. Buttons: no full stop, sentence case ("Продать нижний уровень"). "Send to..." keeps its three dots if it appears: three full stops, not the ellipsis character.
- Sentence case. Capitalise: Община, План, Бюро, Общая книга, planet and market names. Lower case: цикл, кредиты, квота, пятицикловый (when used), commodities in running text ("энергия" is not used for Energy; write Energy in Latin).
- Voice is generated from this text by a TTS model:
  - Use ё wherever it exists (всё, её, подъёмный, паёк, мёртвый, ещё, вторично). Write "всё" not "все" when it means "everything".
  - Write numbers, abbreviations and units out in words. No "т.е.", "и т.д.", "напр.", "шт.", "руб." Use "то есть", "и так далее".
  - Avoid homographs whose stress changes the meaning when a synonym is cheap (за́мок/замо́к, а́тлас/атла́с, по́лки/полки́). If unavoidable, restructure rather than add stress marks.
  - No Latin words except the on-screen terms and placeholders in section 1. No transliterated English slang.
  - No parentheses, no slashes, no square brackets, no arrows. No abbreviations or acronyms.
  - Keep sentences short enough to say in one breath.
- Do not change tags in square brackets that are only in story/events.md notes ([price up: ...]); they are not shown.

## 5. Length

Each id has a max in data/story_text.json ("max", characters). Russian runs about 20 to 35 percent longer than English. Rule:
- Hard limit: at most 1.4 times the English max, rounded down (max 280 gives 392; max 200 gives 280; max 110 gives 154; max 90 gives 126; max 60 gives 84; max 40 gives 56; max 32 gives 44; max 28 gives 39).
- Soft target: stay at or under the English max when that costs no meaning. Cut words, never facts.
- Characters are counted with spaces, placeholders counted as written ({cash_in} is 9 characters).
- Never cut a placeholder or a fact to fit. If a line cannot fit, shorten the style first (drop musing, keep the effect), then report the id to the lead.

## 6. Ten model lines

Hard cases, with the reasoning in brief. Counts are Russian characters against the 1.4 limit.

1. EV_MIN_A1_TITLE (max 40, limit 56), title
   EN: Cinderrest reports a fault
   RU: Cinderrest сообщает о неисправности
   Note: the Latin name is the subject and needs no ending.

2. EV_MIN_A1_BODY (max 280, limit 392), event body
   EN: The Cinderrest crew reports that the lift cable has frayed and the lamps drop out on the lower level. {bot1} runs the next shaft and has offered to lend its crew and cable, for a price. You may sell the lower level, or replace the cable.
   RU: Бригада Cinderrest сообщает: подъёмный трос истёрся, лампы нижнего уровня гаснут. Компания {bot1} ведёт соседний ствол и предлагает одолжить бригаду и трос за плату. Вы можете продать нижний уровень или заменить трос.
   Note: "компания {bot1}" is the apposition; "вы можете" keeps the address plural and genderless.

3. EV_MIN_A1_OPA_BTN (max 28, limit 39), button
   EN: Sell the lower level
   RU: Продать нижний уровень
   Note: infinitive phrase, sentence case, no full stop.

4. EV_MIN_A1_OPA_EFF (max 200, limit 280), effect line
   EN: Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Rivals: {bot1}'s Minerals growth falls a little.
   RU: Получите: {cash_in} кредитов сейчас. Цена: объём рынка Minerals немного снизится на какое-то время. Соперники: у компании {bot1} рост рынка Minerals немного замедлится.
   Note: "{cash_in} кредитов" is correct for 150, 300 and 600. No "но".

5. EV_MIN_A1_OPA_STD (max 90, limit 126), rival line
   EN: {bot1}, Minerals: growth down a little.
   RU: {bot1}, Minerals: рост немного ниже.
   Note: kept in the same short shape as the English because the Competitors log reuses it.

6. EV_MIN_A1_OPA_RES (max 280, limit 392), result, with the dread detail
   EN: A buyer took the lower level and paid on the lift. Your crew works the upper cuts, so volume dipped for a while. {bot} wanted the level and cut elsewhere, and its Minerals growth falls a little. The lamps below still burn, for no one.
   RU: Покупатель забрал нижний уровень и расплатился прямо у подъёмника. Ваша бригада работает на верхних выработках, поэтому объём на какое-то время просел. Компания {bot} хотела этот уровень и сократила расходы в другом месте: её рост на рынке Minerals немного замедлится. Лампы внизу всё ещё горят, ни для кого.
   Note: "компания {bot}"; "ваша" keeps the player genderless.

7. EV_MIL_A1_OPB_STD2 (max 90, limit 126), rival line, boost to a rival
   EN: {bot3}, Military: strength up a little.
   RU: {bot3}, Military: сила немного выше.
   Note: strength is translated here (see section 1 notes).

8. TUT_G3_SEND (max 60, limit 84), tutorial heading
   EN: Right-click Energy, choose Send to.
   RU: Щёлкните правой кнопкой по Energy и выберите Send to.
   Note: on-screen names stay Latin; plain imperative, no flavour. Rewrite as "Нажмите правой кнопкой на Energy, затем Send to." only if length requires.

9. TUT_G3_PICK (max 60, limit 84), tutorial heading
   EN: Click Ashgate to send Energy there.
   RU: Щёлкните Ashgate, чтобы отправить туда Energy.
   Note: no case ending on Ashgate or Energy.

10. TUT_G10_DONE_WHY (max 110, limit 154), _WHY line
    EN: Open Competitors to see shares. Market chain choices change your rivals.
    RU: Откройте Competitors, чтобы увидеть доли. Решения в цепочках рынка меняют ваших соперников.
    Note: "Competitors" is the English menu name; "rivals" is the story word and is translated.

Also model a _WHY with a number-free reason: TUT_G5_UPKEEP_WHY. EN: A ship costs money every cycle, so a route must earn more than it costs. RU: Корабль обходится в деньги каждый цикл, поэтому маршрут должен приносить больше, чем стоит. (Here "деньги" is allowed because the English says "money"; in an event about credits use "кредиты".)

## 7. Checks before a translation is accepted

1. Same set of {placeholders} as the English, byte for byte.
2. No digit in the text.
3. No Latin word except those in section 1 and the placeholders.
4. Within 1.4 times the English max.
5. No exclamation mark, no emoji, no English quotes, no hyphen used as a dash.
6. No gendered past-tense singular addressed to the player.
7. No term from the section 3 forbidden list.

## Owner-side decisions (added by the main session after checking what is on screen in English)

These override anything above that says otherwise.

1. The words strength, growth and tier are on screen in English (Competitors panel labels such as "{bot}: {market} strength down", "growth up", "tier down"). In Russian text write them in Latin, unchanged and never inflected: "Minerals strength", "growth", "tier". Rewrite the sentence around them ("рынок Minerals: strength вырос") rather than inflecting.
2. The ship name Skerrit (button "Buy Skerrit") and Voruun Hauler stay Latin.
3. Workshop names are on screen in English: Fabric, Smelter, Munitions Line, Atelier, Culture Lab stay Latin, never inflected. Do not use the Russian workshop names (ателье, плавильня, ...) from section above. Plain nouns like "smelter" used as an ordinary word in a story sentence (EV46 "The smelter goes cold") may be Russian ("плавильня"), because the story is not naming the building shown in the UI.
4. The chain fill-in phrases CH_CUT, CH_CUT_LOW, CH_CUT_STD, CH_CUT_STD_LOW, CH_SIZE_S, CH_SIZE_M, CH_SIZE_L, CH_EFFECT_LINE, CH_FX_*, CH_RIVALS_LABEL are inserted into event sentences through {cut}, {cut_std}, {get}, {cost}, {rivals} and size words. They are in scope and get Russian versions. Because they are dropped into sentences, write them so they fit the grammar of the sentences that use them: check every EV_ sentence that contains the placeholder, and keep each fill-in phrase grammatically neutral (a verb phrase in the 3rd person singular for {cut}, an adverb for the size words) so all uses read correctly.

## Terms fixed by the review (2026-11-04, copy editor; binding for all ru texts)

| English | Russian |
|---|---|
| tech progress | технологический прогресс; "{n} единицы технологического прогресса" |
| workshop with its on-screen name | мастерская Smelter / Atelier / Munitions Line, лаборатория Culture Lab (apposition, name never inflected) |
| trip cost (label) | Trip cost (Latin, never inflected): "Trip cost одного маршрута" |
| Ship upkeep, Sell price | Latin, never inflected |
| strength, growth, tier | Latin; frame "у компании {bot} strength на рынке Biotech немного снизится" |
| volume | объём Minerals / Military / Luxury / Biotech (no "объём рынка") |
| price up / down (market) | рынок Luxury подорожает / подешевеет (effect lines); "цены выросли / упали" in results |
| rival loses ground (tier cut, no fill-in) | сдала позиции на рынке X |
| crew | бригада (mine, workshop, hands), экипаж (ship only) |
| hull (as a ship) | корабль (never "корпус": stress trap); "корпус" only for a literal hull plate |
| depot | пункт хранения |
| ledger (generic) / Common Ledger | журнал / Общая книга |
| glimmers | искры |
| claim (mining) / claim (aisle right) | заявка / право первой очереди на ряд |
| slot / seat at the call / call | ячейка / место на торгах / торги |
| grower's stock | запасы производителя |
| cold chain | холодовая цепь |
| standing buyer | постоянный покупатель |
| survey / survey office | разведка / контора разведки |
| cut (a mine working) | выработка |
| undercut | обойти по цене |
| treaty office | договорное ведомство |
| in dock order | в порядке очереди на причале |
| fixed price | фиксированная цена |
| Cost: label | Цена: (kept; "Цена: рынок X подешевеет" avoids the echo) |

Fill-ins: {cut} follows "компания {bot} ... на рынке X" (3rd person verb phrase); {cut_std} follows "{bot}, X:". Cycles form: "на срок, циклов: {n}" (no plural choice needed). Batches: "Партий за цикл: +{n}".


## Override of 2026-11-09
The "Owner-side decisions" and "Terms fixed by the review" tables above that keep strength, growth, tier, Ship upkeep, Sell price, Trip cost, workshop names, Skerrit Latin or write "мастерская Smelter" are superseded by section 1. Placeholder-world and house rules above stand.
