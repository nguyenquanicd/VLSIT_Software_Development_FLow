# sdf-design — Step 3: Design / Bước 3: Thiết kế

## Purpose / Mục đích

Turns the chosen option into a design that can be built and checked: architecture, data, interfaces, screens, a memory budget per component, a threat model and a test strategy.

Biến phương án đã chọn thành thiết kế có thể xây dựng và kiểm chứng: kiến trúc, dữ liệu, giao diện, màn hình, ngân sách bộ nhớ cho từng thành phần, mô hình mối đe dọa và chiến lược kiểm thử.

## Functions / Chức năng

- Components, data model, interfaces, user-interface states. / Thành phần, mô hình dữ liệu, giao diện giữa các thành phần, trạng thái màn hình.
- Resource design: allocation, mechanisms, measurement plan. / Thiết kế tài nguyên: phân bổ, cơ chế, kế hoạch đo.
- Security design: STRIDE threat model and baseline controls. / Thiết kế bảo mật: mô hình mối đe dọa STRIDE và các biện pháp nền.
- Traceability from every requirement to a component; confirmation in four chunks. / Truy vết từ mỗi yêu cầu tới thành phần; xác nhận theo bốn phần.
- Cost design: cost drivers and the mechanisms that keep them low. / Thiết kế chi phí: các yếu tố tạo chi phí và cơ chế giữ chi phí thấp.

## Inputs and output / Đầu vào và đầu ra

Input: approved requirements and chosen option. Output: `docs/sdf/03-design.md`, the Step 3 section and the "Design (3)" ledger column.

Đầu vào: yêu cầu đã duyệt và phương án đã chọn. Đầu ra: `docs/sdf/03-design.md`, mục Step 3 và cột "Design (3)" của sổ bằng chứng.

## Use / Cách gọi

    Claude Code:  /sdf-design
    Codex:        $sdf-design

Normally started by `sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `sdf-flow` gọi. Cài đặt: xem README của repository.
