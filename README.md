Introduction to HW-SW Codesign
===
2018 Spring - Course - NCTU Introduction to HW-SW Codesign

# Introduction
- 本次 LAB 的目的是要加速 find face
  - find face: 一個簡易的人臉辨識程式
  - 假設有一張照片名為 group 裡面有一群人，我們要找 32X32 的 face 在 group 中的位置
- 利用 master dma burst mode 抓資料，減少讀取資料的時間
- 使用大量的平行化，同時算好幾個 sad 和 face，使速度顯著提升
  - sad: 32X32 的 face - group 的絕對值

# 架構

<img src="https://i.imgur.com/9n5zmkl.png" width="480"/>

## Master
- 用 data burst 的方式讀取圖片的資料，當讀取 face 時，burst length 為 8 個 words，讀取 group 時，burst length 為 9 個 words
- 用 9 個 words 的原因是當 master 讀取圖片時，使用的 source address 必為4的倍數，而 9 個 words 的長度可以一次做 4 個 sad，因此下一個 source address 為現在的 source address + 4

  <img src="https://i.imgur.com/HEOeXp0.png" width="320"/>

- 用一個 finite state machine 把跨過 4K boundary 的 burst 切成兩段

  <img src="https://i.imgur.com/mT1HN0w.png" width="240"/>

## Slave
- 控制什麼時候計算 sad
  - (Update) 現在想想不應該為了省一個 clock cycle 就省略等待抓資料完成的 state，這就是為什麼當初很難 debug，而且如果以後要擴充也留了技術債

  ![](https://i.imgur.com/7k3lAUI.png)

- 控制什麼時候抓資料

  ![](https://i.imgur.com/AQHT0ln.png)

## BRAM
- 我一共用了 5 個 BRAM 儲存 group 和 4 個 face 的資料
- 雖然讀取跟寫入都要花一個 cycle，但可以儲存 4 張臉，也就是可以平行計算 4 張臉的 sad

## Compute sad
- 包含了 4 個 compute sad kernel，也就是同時算 4 個 sad
- 它是 slave 跟 compute sad kernel 的介面，會找出 4 個 sad 中最小的 sad。

## Compute sad kernel
- 單純的 absolute difference 和 adder tree，輸出 sad 的值
  - 用 adder tree 是因為我們不能一次算完 32X32 的 absolute，一次算完太久會造成 critical path 的問題
- 設計目的是為了能快速平行計算 n 個 sad，並在速度和資源中取得平衡

# Results
- 從純軟體算 1 張臉 3 s，到現在 4 張臉 239 ms
- 要設計成 compute sad 的時間比 data burst 的時間還長，這樣才不會浪費時間在資料傳輸上
- (Update) 現在想想這個設計速度跟資源使用量的平衡不好，為了速度用了太多的資源，
- Please refer to my report for more details.
