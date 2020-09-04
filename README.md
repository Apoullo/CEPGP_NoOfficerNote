# CEPGP NoneOfficeNote

CEPGP NoneOfficeNote is a plugin of CEPGP addon.

It will store the EPGP record into the local instead of the office note.

The members of the raid doesn't need to be at the same guild.

It is convenient for teams which using Google sheet to record EPGP.

# How to use
## Before raiding
1. type /cepnon to show up the window.
2. Click [Import Standings].
3. Select and copy all the values ​​of the three fields of the Google sheet "ID EP GP", paste them into the [Import EPGP] window, and click [Import Standings].

Note: 
1. After importing, the previous EPGP Traffic will be cleared.
2. The imported EP/GP value will be rounded downward to its nearest integer

## After raiding
1. type /cepnon to show up the window.
2. Click [Export Standings]. 
3. Click [Select Gained EP], press crtl+c to copy, and paste it into your Google sheet.
4. Click [Select Gained GP], press crtl+c to copy, and paste it into your Google sheet.

## Note
1. The ID of the imported list must be ** exactly the same as the game ID **
2. When the word "guild" appears, it means that the ID is on the import list.

## Alt Management
In the option, you can set **Recode EPGP on Main character**

If you use the Alt to raid, the EPGP obtained will be recorded on the Main character.

The link table of the Main/Alt is the CEPGP Alt Management setting.

You can set the number of EP% obtained.

**The Alt ID cannot be listed on the imprted data**

## Does not support
1. Stanby functions
2. Save Standings/Restore Standings
3. Add/Decay/Reset Guild EPGP
4. All operations related to the guild Rank

Compatible with CEPGP version 1.12.25

##

CEPGP NoneOfficeNote 是 CEPGP addon 的 plugin。

它會讓原本存在幹部註記裡的 EP,GP 資訊，改存在本地端。

出團人員名單不需要都是同個公會的人。

方便使用Google表單紀錄EPGP的團隊使用。

# 使用方式
## 出團前
1. 打 /cepnon 叫出視窗
2. 點選 [導入列表] 
3. 將Google表單 ID EP GP 三個欄位的值全選複製起來，貼到 [Import EPGP] 的視窗裡，點選 [Import Standings]

註: 
1. 導入列表後會清除之前的EPGP明細
2. 導入的 EP/GP 數值會使用無條件捨去法化為整數

## 出團後
1. 打 /cepnon 叫出視窗
2. 點選 [匯出列表]
3. 點選 [Select Gained EP]，按下 crtl+c 複製，到 Google表單 的本次 EP 欄貼上
4. 點選 [Select Gained GP]，按下 crtl+c 複製，到 Google表單 的本次 GP 欄貼上

## 注意
1. 匯入名單的ID必須與遊戲ID **完全相同**
2. 有出現 guild 的字眼時，是代表該 ID 有無在匯入名單上

## 分身管理
在 option 裡可以設定 **紀錄EPGP到本尊身上**

若用分身出團時獲得的EPGP會記錄在本尊身上

本尊/分身的對應表是使用CEPGP原本的分身設定列表

可以設定分身出團時所獲得的 EP %數

**分身ID不可以列在出團表單上**

## 不支援
1. 候補功能
2. 保存列表/恢復列表
3. 增加/衰減/重置公會EPGP
4. 所有有關 Rank 的操作

相容於 CEPGP version 1.12.25
