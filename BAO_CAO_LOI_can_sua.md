# Báo cáo lỗi cần sửa — `Group04_ProjectQuiz1.Rmd`

> Rà soát toàn file sau khi merge main vào nhánh `Problem1`. File **vẫn render được**,
> nhưng có các lỗi dưới đây. Số dòng theo bản merge hiện tại (có thể lệch khi chỉnh);
> mỗi lỗi kèm tên chunk / đoạn text để dễ tìm lại. Đã kiểm chứng bằng R.

## Bảng phân công nhanh

| # | Lỗi | Vùng / người phụ trách | Mức độ |
|---|---|---|---|
| 1 | Condition number ở 2B tính sai scale → kết luận sai | 2B (Ridge) | 🔴 Nặng |
| 2 | Inline R hỏng, chữ "r round(...)" lọt vào PDF | 2C (Lasso) | 🔴 Nặng |
| 3 | Header `## 3A`, `## 3B` bị lặp 2 lần | Problem 3 | 🔴 Nặng |
| 4 | Định nghĩa Gram matrix G mâu thuẫn trong 3A | Problem 3 | 🟠 Vừa |
| 5 | Scaling hàm mục tiêu 3A/3B không khớp glmnet | Problem 3 | 🟠 Vừa |
| 6 | `save()` ghi file tạm vào repo mỗi lần render | 1B (chung) | 🟠 Vừa |
| 7 | Dòng debug `sum(is.na(...))` in ra vô nghĩa | 1B (chung) | 🟠 Vừa |
| 8 | Parity guard bị mất khi merge | 1A (chung) | 🟡 Nhỏ |
| 9 | Mục 2D mất tiêu đề + còn placeholder (0.80đ chưa làm) | 2D | 🟡 Nhỏ |
| 10 | Placeholder template còn lộ trong PDF | Toàn bài | 🟡 Nhỏ |
| 11 | Hình ở 1C thiếu nhãn/caption | 1C | 🟡 Nhỏ |
| 12 | Lỗi vặt: dấu `*` thừa, đoạn văn trùng, chunk không tên | 2B, 2C | 🟡 Nhỏ |
| 13 | Kết luận VIF ở 1C sai + tự mâu thuẫn, chọi với 2A | 1C | 🟠 Vừa |

---

## 🔴 LỖI NẶNG — sai kết quả hoặc hiển thị lỗi, phải sửa trước khi nộp

### 1. Condition number ở 2B tính SAI scale → kết luận khoa học ngược

**Vị trí:** Problem 2B, chunk "Lambda min" (~dòng 723) và "Lambda 1se" (~dòng 737).

**Lỗi:** Code tính eigenvalue từ `crossprod(x_train)` tức **X'X**, không chia cho n:
```r
g <- crossprod(x_train)          # = X'X  (SAI)
eigen <- eigen(g)$value
cat("Condition number:", (max(eigen) + lambda)/(min(eigen) + lambda), "\n")
```
Nhưng helper `safe_condition_numbers` và Problem 3A đều định nghĩa **G = X'X/n**, và
λ của glmnet nằm trên thang mục tiêu (1/2n), nên λ phải cộng vào eigenvalue của **X'X/n**.

**Hậu quả (đã kiểm chứng bằng R, λ_min ≈ 0.23):**

| Cách tính | Condition number ridge |
|---|---|
| Code hiện tại (X'X) | **20.23** |
| Đúng (X'X/n) | **8.96** |
| κ khi chưa ridge (X'X/n) | 20.6 |

Vì eigenvalue của X'X lớn gấp ~77 lần, cộng λ=0.23 gần như không đổi tỉ số → ra 20.2,
tức **gần bằng lúc chưa ridge (20.6)**. Do đó narrative kết luận SAI:
> "condition number decreased only slightly from 20.2 to 19.07 ... minimal improvement
> in numerical stability" (~dòng 746) và "may not be sufficiently stable" (~dòng 732).

Thực tế với scale đúng, ridge cắt condition number **20.6 → 9.0 (hơn một nửa)**. Đây đúng
ra là bằng chứng số chính cho Problem 3A, nhưng đang bị kết luận ngược lại.

**Cách sửa:** Dùng helper có sẵn thay cho code tự viết:
```r
safe_condition_numbers(x_train, lambda = ridge$lambda.min)   # trả về c(gram, ridge)
safe_condition_numbers(x_train, lambda = ridge$lambda.1se)
```
Rồi **viết lại nhận xét**: ridge giảm condition number đáng kể (20.6 → ~9.0 tại λ_min),
cho thấy ridge cải thiện rõ tính ổn định số, đúng như lý thuyết ở 3A.

---

### 2. Inline R hỏng ở 2C — chữ "r round(...)" in thẳng ra PDF

**Vị trí:** Problem 2C, đoạn văn dưới chunk `lasso-1se` (dòng 835) và dưới
`lasso-cv-error-1se` (dòng 846).

**Lỗi:** Thiếu dấu backtick. Đang viết:
```
... selects $\lambda_{\text{1se}} = r round(lambda_1se, 4)$ ... CV-MSE) is r round(cv_mse_1se, 4)
```
Phải là `` `r round(lambda_1se, 4)` ``. Vì thiếu backtick, PDF **in ra nguyên chữ**
"r round(lambda_1se, 4)" và "r round(cv_mse_1se, 4)" (đã xác nhận: 2 chỗ trong PDF).

**Lỗi kèm theo:** Dòng 835 dùng biến `cv_mse_1se` nhưng biến này mãi tới chunk
`lasso-cv-error-1se` (dòng 839–844) mới được tính. Nếu chỉ thêm backtick vào dòng 835
sẽ báo lỗi "object 'cv_mse_1se' not found".

Ngoài ra dòng 835 và 846 gần như **trùng nội dung** (đều nói λ_1se giữ 3 biến lcavol,
lweight, svi).

**Cách sửa:** Xóa hẳn đoạn dòng 835 (đoạn bị lỗi và trùng), giữ đoạn 846 (nằm SAU khi
`cv_mse_1se` đã tính) và thêm backtick cho nó:
```
... selects $\lambda_{\text{1se}} = `r round(lambda_1se, 4)`$, resulting in a
five-fold CV-MSE of `r round(cv_mse_1se, 4)`. ...
```

---

### 3. Header `## 3A` và `## 3B` bị lặp 2 lần

**Vị trí:** Problem 3 — `## 3A. Ridge and conditioning` ở dòng 920 VÀ 929;
`## 3B. Lasso optimality and soft thresholding` ở dòng 1100 VÀ 1104.

**Lỗi:** Mỗi mục có 2 header cùng số → mục lục (TOC) hiện trùng, đánh số section bị loạn.
Nguyên nhân: merge rối giữa các nhánh WorkSpace trên main. Header thứ nhất chỉ chứa
dòng italic hướng dẫn + chunk TODO trống; header thứ hai chứa nội dung thật.

**Cách sửa:** Với mỗi mục, xóa header trùng thứ nhất cùng phần rác của nó:
- 3A: xóa dòng 920–927 (header trùng, dòng `*Write the ridge derivation...*`, và chunk
  `ridge-conditioning` chỉ có comment TODO), giữ lại header + nội dung từ dòng 929.
- 3B: xóa dòng 1100–1102 (header trùng + dòng `*Derive the zero/nonzero...*`), giữ từ 1104.

> Lưu ý: chunk TODO `ridge-conditioning` (924–927) đang trống. Nếu muốn có bảng
> condition number cho 3A thì điền `safe_condition_numbers(x_train, ridge$lambda.min)`
> vào đây (liên quan lỗi #1), rồi mục 3C mới nối số với lý thuyết được.

---

## 🟠 LỖI VỪA — nhất quán / logic

### 4. Định nghĩa Gram matrix G mâu thuẫn trong 3A

**Vị trí:** Problem 3A — dòng 964 viết `G = X'X`; dòng 1036 viết `G = (1/n) X'X`.

**Lỗi:** Hai định nghĩa khác nhau của cùng ký hiệu G trong cùng một mục. Kết quả số và
helper đều dùng X'X/n. Liên quan trực tiếp lỗi #1.

**Cách sửa:** Thống nhất **G = X'X/n** ở mọi chỗ trong 3A (sửa dòng 964 và các công thức
theo sau cho đồng bộ với dòng 1036).

### 5. Scaling hàm mục tiêu 3A/3B không khớp nhau và không khớp glmnet

**Vị trí:** 3A dòng 938 dùng `½‖y−Xb‖² + (λ/2)‖b‖²`; 3B dòng 1108 dùng `‖y−Xb‖² + λ‖b‖`
(không có ½ hay 1/2n). glmnet thực tế dùng `(1/2n)‖y−Xb‖² + λ·P(b)`.

**Lỗi:** Ba scale khác nhau. Đạo hàm trong 3A vẫn đúng, nhưng khi mục **3C** nối λ số (từ
2B/2C, tính theo glmnet) với công thức lý thuyết thì thang λ sẽ vênh.

**Cách sửa:** Chuẩn hóa cả 3A và 3B theo đúng convention glmnet `(1/2n)‖y−Xb‖² + λ...`
để λ trong lý thuyết cùng thang với λ số.

### 6. `save()` ghi file tạm vào repo mỗi lần render

**Vị trí:** chunk `split-and-scale` (1B), dòng 378.
```r
save(x_train, y_train, x_test, y_test, analysis_data, train_id, test_id, foldid,
     file = "data/tmpData.RData")
```
**Lỗi:** Mỗi lần render lại ghi một file `.RData` lạ vào thư mục `data/`. Chắc để truyền
biến sang các file `src/*.Rmd`, nhưng báo cáo chính không cần và không nên có side effect này.

**Cách sửa:** Xóa dòng 378 khỏi báo cáo chính. Nếu `src/` cần dữ liệu thì tự sinh lại
trong file đó (đã có seed cố định nên tái lập được).

### 7. Dòng debug thừa in ra `[1] 0`

**Vị trí:** chunk `split-and-scale` (1B), dòng 376: `sum(is.na(analysis_data))`.

**Lỗi:** Biểu thức trần in `[1] 0` ra giữa báo cáo, vô nghĩa (đã có guard `anyNA` ở 1A rồi).

**Cách sửa:** Xóa dòng 376.

### 13. Kết luận VIF ở 1C sai, tự mâu thuẫn, và chọi với 2A

**Vị trí:** Problem 1C, đoạn ngay dưới chunk `eda-vif` (~dòng 484).

**Nguyên văn hiện tại:**
> "There is **no significant multicollinearity** present in this model. Because all
> VIF values are safely below 5, the independent variables are **not highly
> correlated with one another**. The regression model's coefficient estimates are
> **mathematically stable**, and no variables need to be dropped or transformed."

**Ba vấn đề:**

1. **"Coefficient estimates are mathematically stable" là SAI.** Chính 2A chứng minh
   ngược lại: hệ số của `lcp` **đổi dấu** (β̂ ≈ −0.04) dù tương quan biên của `lcp`
   với `lpsa` là dương (+0.59). Đó đúng là định nghĩa của hệ số *không* ổn định.

2. **"Not highly correlated with one another" mâu thuẫn với chính 1C.** Đoạn
   correlation phía trên (~dòng 409) tự viết: *"some stronger positive correlations
   were observed, particularly between gleason and pgg45 (r = 0.78), lcavol and lcp
   (r = 0.68), and svi and lcp (r = 0.69)"*. Không thể vừa nói có tương quan mạnh
   vừa nói "không tương quan cao".

3. **Chọi với 2A.** 2A kết luận đa cộng tuyến **vừa phải** (VIF max 3.35 < 5) nhưng
   vẫn đủ lật dấu `lcp`. Người chấm đọc liền 1C → 2A sẽ thấy hai mục nói ngược nhau.

**Lý do đúng về mặt thống kê:** VIF < 5 chỉ nói **không có biến nào cần loại bỏ** —
nó **không** bảo đảm mọi hệ số đều ổn định. Một biến gần như không có tín hiệu riêng
(`lcp` có p ≈ 0.78) vẫn có thể bị lật dấu chỉ với đa cộng tuyến vừa phải, vì sau khi
`lcavol` hút hết phần phương sai chung thì phần còn lại của `lcp` gần như là nhiễu.

**Cách sửa (gợi ý viết lại):**
> "All VIF values are below the conventional threshold of 5 (largest: pgg45 at 3.35,
> lcp at 3.29), so multicollinearity is **moderate rather than severe** and no
> variable needs to be dropped. Moderate collinearity is nevertheless enough to
> destabilize an individual coefficient when a predictor carries little independent
> signal — 2A shows exactly this for `lcp`, whose sign flips. This is the instability
> that ridge and lasso are expected to control."

Sửa xong thì 1C và 2A khớp nhau và cùng dọn đường cho 3A.

---

## 🟡 LỖI NHỎ — dọn dẹp / chất lượng

### 8. Parity guard bị mất khi merge
**Vị trí:** chunk `data-configuration` (1A, ~dòng 189). Dòng
`stopifnot(group_number %% 2L == 0L)` (chốt nhóm chẵn → prostate.csv) đã có trước đây
nhưng bị bản mở rộng 1A trên main ghi đè mất. Cân nhắc thêm lại đầu chunk.

### 9. Mục 2D mất tiêu đề và còn placeholder
**Vị trí:** dòng 878 chỉ ghi `## 2D`, thiếu `. Controlled comparison and locked core model`.
Nội dung còn là placeholder (`# Build a comparison...`, `[method and reason]`). Đây là mục
**0.80 điểm** — cao nhất trong Problem 2 và chưa làm. Cần bổ sung tiêu đề + nội dung.

### 10. Placeholder của template còn lộ trong PDF
Đề yêu cầu "Remove instructional comments from the final report". Cần gỡ trước khi nộp:
- Comment hướng dẫn đầu file (dòng 30–35)
- Ô `[Work]` / `[Check]` trong bảng đóng góp (dòng 44–47)
- Abstract placeholder (dòng 51) — viết sau cùng khi xong cả bài
- Các dòng italic hướng dẫn còn sót: dòng 922, 1102, 1389 (và mọi dòng `*...*` tương tự)

### 11. Hình ở 1C thiếu nhãn / caption
Mục 5B chấm "readable labeled figures". Hiện:
- `hist(y_train)` (dòng 416) dùng tiêu đề/nhãn mặc định.
- Các cụm `par(mfrow=c(2,4))` (dòng 423, 489) không có `fig.cap`, trục thiếu nhãn rõ.

Nên đặt `main=`, `xlab=`, và thêm `fig.cap=` cho các chunk hình.

### 12. Lỗi vặt
- Dòng 795: "retains 5 non-zero predictors**\***" — thừa dấu `*`.
- 2C: đoạn dòng 837 và 848 lặp gần nguyên văn ("retains only three non-zero predictors
  lcavol, lweight, and svi..."). Nên gộp.
- 2B: nhiều chunk không đặt tên (dòng 721, 735, 749, 761) và dòng 761 viết ```{R}``` hoa.
  Không lỗi nhưng nên đặt tên nhất quán để dễ tham chiếu.

---

## Gợi ý thứ tự sửa
1. Sửa #2, #3, #6, #7 trước (rõ ràng, nhanh, ít tranh cãi).
2. Sửa #1 + #4 + #13 cùng nhau — cả ba đều xoay quanh "ridge/đa cộng tuyến giúp được
   bao nhiêu", và hiện đang kết luận sai hoặc chọi nhau. Đây là nhóm quan trọng nhất
   về nội dung.
3. #5 khi bắt đầu làm 3C.
4. #8–#12 dọn cuối, trước khi nộp.

> **Ghi chú:** phần 1A và 2A đã được rà và sửa xong (số liệu tự tính bằng inline R,
> bỏ đoạn lặp, Cook's distance dán nhãn theo dòng gốc và nối với anomaly `lweight`
> của 1C, bảng metrics có thêm CV SE). 2A hiện đã mô tả đa cộng tuyến ở mức **vừa
> phải** và dẫn lại bảng VIF của 1C — nên sau khi sửa #13, hai mục sẽ khớp nhau.
