# sdf-review — Step 6: Review / Bước 6: Rà soát độc lập

## Purpose / Mục đích

Independent review of the built app: traceability, code, an independent re-measurement of every resource budget, and a security audit. Blocks release on Blocker and High findings.

Rà soát độc lập ứng dụng đã xây dựng: truy vết, mã nguồn, đo lại độc lập mọi ngân sách tài nguyên và kiểm toán bảo mật. Chặn phát hành nếu còn phát hiện mức Blocker hoặc High.

## Functions / Chức năng

- `scripts/scan-secrets.ps1`: fallback secret scan, redacted output. / Quét bí mật dự phòng, kết quả được che.
- `scripts/audit-deps.ps1`: runs the audit tool of each ecosystem; a missing tool is reported as not audited, never as a pass. / Chạy công cụ kiểm tra của từng hệ sinh thái; thiếu công cụ được báo là chưa kiểm tra, không bao giờ là đạt.
- Severity scale, waivers recorded in the user's own words. / Thang mức độ, ngoại lệ ghi bằng lời của người dùng.
- Cost audit: hidden or recurring costs, licences, usage-priced services against their caps; library scripts run only after the integrity check. / Kiểm toán chi phí: chi phí ẩn hoặc định kỳ, giấy phép, dịch vụ tính theo mức dùng so với ngưỡng; script thư viện chỉ chạy sau khi kiểm tra toàn vẹn.

## Inputs and output / Đầu vào và đầu ra

Input: the approved build. Output: `docs/sdf/06-review.md`, the Step 6 section and the "Independent (6)" ledger column.

Đầu vào: bản build đã duyệt. Đầu ra: `docs/sdf/06-review.md`, mục Step 6 và cột "Independent (6)" của sổ bằng chứng.

## Use / Cách gọi

    Claude Code:  /sdf-review
    Codex:        $sdf-review

Normally started by `sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `sdf-flow` gọi. Cài đặt: xem README của repository.
