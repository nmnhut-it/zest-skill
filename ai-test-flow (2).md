ai-test-flow

Em xin gửi lại góc nhìn của em ạ. 

Nhìn chung code do AI gen rất ngon, coverage rất tốt cho nhiều project, đặt biệt là các dạng project phổ biến trong SWE (ví dụ như xử lí CRUD, log, web, ngân hàng ...)

# Một vài pitfall em hay gặp phải

## 1. AI viết lại 1 impl khác để test, hoặc mock gần hết code hoặc param. 
Hậu quả: Mock cực kì khó maintain. khi code đổi 1 thì phải đổi test 10, và test cũng không expose được bug trong 1 số case, vì mình đang test 1 impl khác chứ không phải code được chạy thực tế 

Bản chất của Mock là dùng reflection hoặc instrumentation để viết lại code, cho nên chạy rất chậm. 

Thường em làm: 
- Bắt buộc AI né mock hết mức có thể. Nếu bắt buộc phải mock, prompt cho AI refactor đoạn code để không cần phải mock. 

Ví dụ (chỉ mang tính chất minh họa cho ý tưởng): 
Code gốc:
```java
class TimeProvider {
    // theo code này thì cần mock hàm getMillis để test
    long getMillis() { return System.currentTimeMillis(); } 

    public static TimeProvider getInstance(); // a global instance for the project
}

class EventTime{
    private TimeProvider time; 
    private long eventStartTime; 
    private long eventEndTime; 

    // theo code này thì cần mock hàm loadDB này hoặc Whitebox.set 2 biến time để test 
    void loadEventTimeFromDB(); 

    bool isInEventTime(){
        // muốn dùng 1 time provider duy nhất để đảm bảo nhất quán về thời gian cho project
        // cần phải mock Time Provider 
        long now = TimeProvider.getInstance().getMillis(); 
        return this.eventStartTime <=  now && now  <= this.eventEndTime; 
    }    
} 
```

thì khi prompt **"Refactor for better testability** thì AI có thể sẽ viết thành như vầy 

```java
class TimeProvider {
    Clock clock; // use java clock for time-related testing 
    long getMillis() {
        return clock.millis(); 
    }
    public static TimeProvider getInstance(); 

    void stubTime(long millis){
        clock.setMillis(millis); 
    }

    void resetStub(){
        clock.reset(); 
    }
}

class EventTime{
    // đổi thành package-local để không cần mock/reflection trong lúc integration test (không phải unit test)
    long eventStartTime; 
    long eventEndTime; 

    void loadEventTimeFromDB(); 

     bool isInEventTime(){
        loadEventTimeFromDB(); 
        return isInEventTime(time.getMillis(), 
     }
    // tách ra 1 hàm để test logic, AI có thể test hàm này mà không cần mock gì cả
    // Ví dụ: 
    /** 
       public void test2(){
           TimeProvider.getInstance.stubTime(0) ;   
           assert codeUnderTest.isInEventTime(-1,1); 
        }
        như vậy cái này được tách thành 2 giai đoạn: 
        - test #1: check xem có load đúng event start/end time hay không --> phần này test trên DB thật, không mock (test tay hoặc dùng testcontainers)
        - test #2: check xem logic có đúng hay không 
    */

    public bool isInEventTime(long start, long end){ 
        // nếu không cần dùng 1 time provider chung cho cả proj thì có thể pass now vào luôn
        long now = TimeProvider.getInstance().millis(); 
        return start <=  now && now  <= end; 
    }    
} 

```


## AI gen ra các test khá ít giá trị sử dụng hoặc thiếu test cases 

Trong các case khó test, thường AI sẽ gen ra các test case khá vô dụng. 

Em thường prompt cho nó viết integration test với testcontainers luôn. Đồng thời review test case cẩn thận trước khi viết 

```java 

class RealRepo{
    User find(int userId){
        // trong real impl, có trường hợp chỗ này sẽ nổ exception khi user không tồn tại (tùy thuộc vào impl của couchbase client, official couchbase SDK thì sẽ nổ) 
        // cho nên TestRepo này không catch được bug 
        String raw = couchbase.get("my_u_xo_" + userId); 
        if (raw == null || raw.isEmpty()) 
            return null ;
        return Json.parse(raw, User.class); 
    }
} 
class TestRepo extends RealRepo{
    ConcurrentHashMap<String, String> data; 
    User find(int userId); 
}
 @Test
    public void testLoadDB() { 
    
        int nonExistentUserId = 99999;
        // set up  

        // Vì test repo là test-impl nên không catch được bug khi chạy prod, 
        // và khi code thay đổi (thêm, xóa hàm) thì cũng phải viết lại cái này 
        var testStatsRepo = new TestRepo();  
        /// .... 
        /// 
        // bản chất cái này là test ConcurrentHashMap và phần deserialization
        // --> vậy thì mình nên tách thành 2 step: test load từ DB (dùng testcontainers)
        // và test deserialization (từ string/byte[] thành class mình muốn)
        assertNull("Stats should return null", testStatsRepo.find(nonExistentUserId)); 
    }
```
Khi prompt AI xài test container với couchbase & docker
```java 
class RealRepoIntegrationTest {
    
    private static CouchbaseContainer couchbase;
    private static Cluster cluster;
    private static Collection collection;
    private RealRepo repo;
    
    @BeforeAll
    static void setupContainer() {
        // Start Couchbase container
        couchbase = new CouchbaseContainer(
            DockerImageName.parse("couchbase/server:7.2.4")
        )
        .withBucket("test-bucket")
        .withCredentials("admin", "password123");
        
        couchbase.start();
        
        // Connect to Couchbase
        cluster = Cluster.connect(
            couchbase.getConnectionString(),
            couchbase.getUsername(),
            couchbase.getPassword()
        );
        
        var bucket = cluster.bucket("test-bucket");
        bucket.waitUntilReady(Duration.ofSeconds(30));
        collection = bucket.defaultCollection();
    }
    
    @BeforeEach
    void setup() {
        // Inject real Couchbase client vào RealRepo
        repo = new RealRepo(cluster, "test-bucket");
    }
    
    @AfterEach
    void cleanup() {
        // Clean up test data
        try {
            collection.remove("my_u_xo_1");
            collection.remove("my_u_xo_2");
        } catch (Exception ignored) {}
    }
    
    @AfterAll
    static void tearDown() {
        if (cluster != null) cluster.disconnect();
        if (couchbase != null) couchbase.stop();
    }
    
    @Test
    @DisplayName("Should return user when exists in DB")
    void testFindExistingUser() {
        // Given
        int userId = 1;
        String userJson = "{\"id\":1,\"name\":\"John Doe\",\"email\":\"john@example.com\"}";
        collection.upsert("my_u_xo_" + userId, userJson);
        
        // When
        User user = repo.find(userId);
        
        // Then
        assertNotNull(user);
        assertEquals(1, user.getId());
        assertEquals("John Doe", user.getName());
    }
    
    @Test
    @DisplayName("Should throw DocumentNotFoundException when user does not exist")
    void testFindNonExistentUser_ThrowsException() {
        // Given: user KHÔNG tồn tại
        int nonExistentUserId = 99999;
        
        // When & Then: official Couchbase SDK sẽ throw exception
        // ĐÂY LÀ BUG mà TestRepo không catch được!
        assertThrows(
            DocumentNotFoundException.class,
            () -> repo.find(nonExistentUserId),
            "Official Couchbase SDK throws DocumentNotFoundException, not return null"
        );
    }
}
```

## AI viết test dựa trên use case và code, nhưng có thể fail với dữ liệu thật 

- Kéo dữ liệu thật về feed vào test luôn. Điều này cũng đảm bảo backward-compatibility khi mình đổi code, user với dữ liệu cũ vẫn load được acc

- Một số test viết ra chạy pass lúc này nhưng fail lúc khác, do cách viết code không đảm bảo tính xác định (non-deterministic), hoặc test này làm nhiễu kết quả của test khác (do cùng chạy chung runtime/database) --> cần check kĩ cách viết test của AI

- Đặc biệt, khi có tương tác về thời gian, tốt nhất là nên fix cứng đồng hồ/thời gian của test. Ví dụ: test đếm số lần điểm danh có thể fail khi chạy vào tháng 2 năm nhuận, vì có 29 ngày, mặc dù logic chạy đúng (do kết quả bị fix cứng). Trường hợp này, nếu "thêm logic" năm nhuận vào thì lại rơi vào bẫy "test the for-test implementation", tức là không test code gốc mà chỉ đối chiếu với 1 impl khác, mà impl này có thể sai.  


## Test cases gen ra cực nhiều, không kiểm soát nổi 

- Em thường cho AI prune bớt, chỉ đảm bảo code coverage và case coverage 
- Viết integration test/ E2E test 

## Về prompt engineering 

- Bắt AI đưa ra 1 bộ tiêu chí theo chuẩn để review, sau đó buộc nó review trên tiêu chuẩn đấy cho các test đã gen - cái này tùy product. Nên set rule cho việc viết test luôn, cũng giống như viết code. 

- Cần có các test mẫu để AI học theo và viết đúng theo code style của mình. Nếu không có code mẫu thì nó sẽ viết theo chuẩn SWE, mà thường là các project ngân hàng hoặc là dịch vụ, khá là khác với ngành gêm  

- Dùng test matrix và các phương pháp viết test cases (hỏi AI, bắt nó liệt kê phương pháp từ SGK của trường ĐH) để đảm bảo **case coverage** bên cạnh code coverage

- Trên máy local, có thể prompt cho AI chạy java/maven/gradle để tự chạy test và tự fix bug của mình luôn (tăng hiệu suất nhưng tốn token ạ :(( )

