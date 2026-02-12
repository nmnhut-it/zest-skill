# Các cách giám sát chất lượng code

## 1. Check dependency
Đánh giá bảo mật của các thư viện dùng trong project.<br>
Bước này chỉ thực hiện khi gắn thêm thư viện mới vào project. Không check liên tục mỗi khi build để tránh ảnh hưởng tốc độ build.<br><br>
Ví dụ: sử dụng org.owasp.dependencycheck trong gradle

## 2. Unit test / Integration test
Phải xác định là code tính năng mới sẽ có unit test để chọn cấu trúc cho phù hợp.<br><br>
Ngoài các **test cơ bản** đúng flow (ứng với client) thì thì phải có các **test ngoại lệ** (ví dụ như dùng tool sửa gói tin hoặc tự viết client gửi gói tin) 
và các **test theo kịch bản** (ví dụ như test user nhận 7 phần quà trong 7 ngày).<br><br>
**Ví dụ 1:** gửi nhiều lần để nhận gói quà ngày thứ 1 trong tính năng tặng quà 7 ngày.<br>
**Ví dụ 2:** trong game có bán 1 item bằng token của event hoặc bằng G, nhưng client gửi lệnh mua gói đó bằng gold

## 3. Check code quality and security
Dùng **SpotBugs / SonarQube** để kiểm tra code. 
Bước này chỉ cần thực hiện vài lần vài lần trong quá trình phát triển tính năng mới và ngay trước khi gửi test. <br>
Không check liên tục mỗi khi build để tránh ảnh hưởng tốc độ build<br>

## 4. Dùng AI check code
Dùng AI để check bug của code<br>
Theo kinh nghiệm cá nhân thì dùng Gemini và ChatGPT cho kết quả khá tốt. Đặc biệt là ChatGPT Codex check code rất tốt.<br><br>

Ví dụ 1: VictoryWheelScene.js (line 1219), sai tên biến state (trong code ghi là sate)
Ví dụ 2: VictoryWheelController.js (line 703), biến maxProgress không tồn tại. Phải so currentProgress với targetValue trong config mới đúng

## 5. Code review bởi dev
Có thể nhờ dev khác review nhanh code mới, xem có các vấn đề lớn gì cần sửa đổi hay không. Nếu giới hạn phạm vi review lại thì có thể chỉ tốn khoảng 15 - 60 phút của bạn dev đó mà thôi.<br>

## 6. Load Test / Stress Test / Benchmark 
Trong thực tế thì không phải tính năng nào cũng sẽ tiến hành Load Test / Stress Test. 
Với các trường hợp đơn giản mình có thể dùng các thư viện Microbenchmarking như jmh để test hiệu suất của một phần code.<br>

## 7. Log monitor
Log monitor phải là log theo một format chuẩn, có thể parse và làm ra report. Ví dụ như ghi log metric và lên report trên Superset.<br>
Khi có log chuẩn report thì sẽ theo các nguyên tắc sau:
1. Viết code theo hướng hoàn toàn không có exception, mỗi khi có exception thì ghi log để sửa ngay.
2. Ghi log tất cả các mã lỗi và làm report trên Superset để theo dõi tỉ lệ thành công và từng mã lỗi. <br>
Ví dụ có nhiều project chỉ ghi lại log thành công nhưng ko ghi lại log lỗi hoặc ghi log lỗi bên log debug (log này không thể parse được)
3. Ghi log thời gian thực hiện của từng loại lệnh. Có thể ghi percentile theo khoảng thời gian để giảm lượng log. Log này rất hiệu quả để theo dõi hiệu suất
4. Định kỳ ghi log tình trạng hệt thống: cpu, mem, ccu...
