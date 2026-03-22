# Advanced Trade Skill Window 2
Improved window for your professions for World of Warcraft vanilla

---

## Turtle WoW Fork

This is a fork of [Shellyoung/AdvancedTradeSkillWindow2](https://github.com/Shellyoung/AdvancedTradeSkillWindow2) with compatibility fixes for **Turtle WoW patch 1.18.1**.

### Patch 1.18.1 compatibility fixes (v2.1.16)

- **Survival profession support** — The new Survival profession can return `nil` recipe names and indices from the game API. Added nil guards in `SelectCraftItem`, `AddRecipe`, and `ATSW_ShowRecipe` to prevent crashes when opening the Survival tradeskill window.
- **`Whittle` tool** — Added the new Survival tool *Whittle* (item ID 42004) to the tool icon/availability lookup table so it displays correctly in the detail panel.
- **`InCombatLockdown()` unavailable** — `InCombatLockdown()` was added in TBC and does not exist in WoW 1.12. Replaced all usages with event-driven tracking via `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED`.
- **UIPanel stack overflow fix** — `ShowUIPanel()` for `area='left'` frames triggers a recursive `UpdateUIPanelPositions` call on Turtle WoW's patched UI, causing a stack overflow. Replaced with `Frame:Show()` + `SetLeftFrame()` directly, removing the save/restore pattern that was also preventing the Escape key from closing the window.
- **`ATSWRecipe_OnClick` nil** — Added the missing global function `ATSWRecipe_OnClick` (called from XML) which handles Ctrl‑click (dress up), Shift‑click (insert link to chat), and right‑click (search auction house) on the large recipe icon in the detail panel.
- **`1then` syntax error** — Fixed a missing space typo (`1then` → `1 then`) in the GetAttributes block that caused a compile failure.
- **CustomSorting nil crash** — Added a nil guard in `ATSWCS_GetItemFromCategories` for recipes that exist in another profession but not the currently open one (defaulting to `'trivial'`).
- **Reagent tooltip column alignment** — Replaced the single concatenated right‑aligned string used for Bags/Bank/Alts counts with three separate fixed‑width center‑justified FontStrings per row, so columns remain aligned regardless of digit count or font rendering.
- **Background artwork draw order** — `ATSWBackground` (profession art) was rendered behind `ATSWBackgroundShadow`, causing the shadow texture to obscure the left panel. Moved background art to ARTWORK sublevel 1 so it draws in front of the shadow layer.

---

![face](https://github.com/user-attachments/assets/cffb06ff-b310-4fb7-ba07-a04caf6e34a3)




  Advanced Trade Skill Window 2 is a replacement for the standard tradeskill window.
  
  Most buttons in ATSW are self-explaining.
  
  ## Features
  ### Tasks
  Selected recipe can be placed into the task list for later craft by clicking on the "Task" button.
  
  ### Task progress timer
  ![Progress face](https://user-images.githubusercontent.com/40469927/189532773-1d745b82-9a98-4db6-919d-4ba86f0b4ab2.png)
  
  Task progress timer represent overall completion of a task. When you start crafting, the progress timer will appear under the task.


  ### Search commands
  
  ![Search commands face](https://user-images.githubusercontent.com/40469927/189532786-b064c4fe-b156-42df-b45f-09bed5b6e3d3.png)
  
  ATSW has a search function built-in. If you type some text into the search box then ATSW will filter the recipe list according to your entry or the following parameters: **:reagent**, **:level**, **:quality**, **:possible**, **:possibletotal**. You can even combine multiple parameters and a text for a name search, like this:
"**leather :level 20+ :quality uncommon+**" - show recipes with the word "leather" in their name, a minimum level requirement of 20 and a minimum quality of "green".
  
  
  ### Necessary reagents list
  
  ![Necessaries face](https://user-images.githubusercontent.com/40469927/189532793-dc72aceb-4eac-4e72-9b86-9cdec2fc4e3e.png)
  
  The "Reagents" button will show you a list of reagents required to craft items in the task list, amount of the reagents you have in your inventory, in your bank, on alternative characters on the same server and if a reagent can be bought from a merchant. By hovering a cursor over the reagent count on alternative characters, you get a list of all alts currently possessing the reagent.

  ATSW can also automatically buy necessary items from a merchant when speaking to him - either manually by clicking a button in the reagents window or automatically when opening the merchant window.
  
  ### Auction shopping list
  
  ![Shopping list face](https://user-images.githubusercontent.com/40469927/189533362-11b26c25-e929-4da5-a89a-39200e7d4507.png)
  
  Auction shopping list appear under the auction window when it is opened. It shows reagents that are necessary to craft the items in the task list. ATSW is compatible with [aux](https://github.com/shirsig/aux-addon-vanilla).
  
  ### Custom categories
  
![custom face](https://github.com/user-attachments/assets/9d2a380f-ec1e-4329-987a-b8fe537eee5f)




  You can create categories and put recipes into them.
  
  
  ### Reporting

  By clicking on an item with chat line opened and Shift key pressed ATSW will add a list of the reagents necessary to create a single item into the chat window. ATSW is compatible with [WIM](https://github.com/shirsig/WIM).
  
  
  ### Key bind
  
  ![Key bind](https://github.com/Shellyoung/AdvancedTradeSkillWindow2/assets/40469927/62774995-5b4c-4c32-88b1-7367ea3de545)


  
  A key can be assigned to call ATSW.
  
  
  ### Configuration
  
  ![Config face](https://github.com/user-attachments/assets/75dac068-a3e6-4f7d-b7ed-abb8f4786ad6)


  
  ATSW can be configured via built-in options menu. The menu can be shown by entering chat command **/atsw config**.


  ### Localization
  Supported languages: English, Русский, Español, Français, Deutsch, 简体中文

  ### Additional add-ons
  ATSW can be enchanced with several additional addons:

  [MissingCrafts](https://github.com/refaim/MissingCrafts) adds a small button that can show what crafting recipes are able to learn.

  ## Installation
  1. Download the following archive: [AdvancedTradeSkillWindow2.rar](https://github.com/Shellyoung/Advanced-Trade-Skill-Window/releases/download/2.1.15/AdvancedTradeSkillWindow2.rar)
  
  2. Extract the folder	**AdvancedTradeSkillWindow2** from the archive and place it into the folder **World of Warcraft\Interface\AddOns**.
  
  ## Credits
  
  ###### Original idea:
  **Rene Schneider** (**Slarti** on EU-Blackhand) in 2006 
  
  ###### Fixes prior to version 2.0.0:
  [**LaYt**](https://github.com/laytya) in 2017
  
  ###### Blizzard Interface source code:
  https://www.townlong-yak.com/framexml/1.12.1
  
  ###### API Documentation:
  https://wowwiki-archive.fandom.com/wiki/Category:Interface_customization

  ###### Thank you
  Suggestions: [flyinbed](https://github.com/flyinbed), [selax1](https://github.com/selax1).
  
  翻译成中文: [flyinbed](https://github.com/flyinbed).
