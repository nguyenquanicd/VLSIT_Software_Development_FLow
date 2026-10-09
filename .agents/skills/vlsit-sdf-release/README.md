# vlsit-sdf-release — Step 7: Release / Bước 7: Phát hành

## Purpose / Mục đích

Prepares and verifies the release: clean release build, hashes, SBOM, signing plans (the user holds the keys), installed-artifact verification against the budgets, rollout, rollback and monitoring.

Chuẩn bị và kiểm chứng phát hành: build release sạch, giá trị băm, SBOM, kế hoạch ký (người dùng giữ khóa), kiểm tra bản đã cài so với ngân sách, triển khai dần, quay lui và giám sát.

## Functions / Chức năng

- Checklists for Windows, Android, iOS and macOS; store rules are checked against current official pages. / Checklist cho Windows, Android, iOS, macOS; quy định store được đối chiếu với trang chính thức hiện hành.
- Every outward action (tag, push, upload, publish) needs explicit confirmation and is recorded. / Mọi hành động ra bên ngoài (tag, push, tải lên, phát hành) cần xác nhận rõ ràng và được ghi lại.
- The AI never handles private keys, certificates or passwords. / AI không bao giờ xử lý khóa riêng, chứng chỉ hoặc mật khẩu.
- Cost check of fees and recurring costs (looked up with the date) and distribution channels compared as options. / Kiểm tra chi phí các khoản phí và chi phí định kỳ (tra cứu kèm ngày) và so sánh kênh phân phối dưới dạng phương án.

## Inputs and output / Đầu vào và đầu ra

Input: the review verdict Pass or Pass with waivers. Output: `docs/sdf/07-release.md`, the Step 7 section and the "Release (7)" ledger column.

Đầu vào: kết luận rà soát Pass hoặc Pass with waivers. Đầu ra: `docs/sdf/07-release.md`, mục Step 7 và cột "Release (7)" của sổ bằng chứng.

## Use / Cách gọi

    Claude Code:  /vlsit-sdf-release
    Codex:        $vlsit-sdf-release

Normally started by `vlsit-sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `vlsit-sdf-flow` gọi. Cài đặt: xem README của repository.

## Author / Tác giả

Nguyễn Quân — [github.com/nguyenquanicd](https://github.com/nguyenquanicd) — [VLSIT_Software_Development_FLow](https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow). Apache License 2.0.
