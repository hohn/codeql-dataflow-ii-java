import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddUser {
    public static Connection connect() {
        Connection conn = null;
        try {
            String url = "jdbc:sqlite:users.sqlite";
            conn = DriverManager.getConnection(url);
            System.out.println("Connected...");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return conn;
    }

    static String get_user_info() {
        System.out.println("Enter name:");
        return System.console().readLine();
    }

    static void write_info(int id, String info) {
        try (Connection conn = connect()) { 
            String query = String.format("INSERT INTO users VALUES (%d, '%s')", id, info);
            conn.createStatement().executeUpdate(query);
            System.err.printf("Sent: %s", query);
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }
    
    static void no_semi(String info) {
        /* no ; allowed */
        // No CodeQL path found when using if (info.contains(";")) { }
        // if (info.contains(";")) {
        //     System.err.printf("invalid string ';' in database write.  Aborting.");
        //     System.exit(1);
        // }
    
        Pattern pattern = Pattern.compile(";", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(info);
        boolean matchFound = matcher.find();
        if(matchFound) {
            System.err.printf("invalid string ';' in database write.  Aborting.");
            System.exit(1);
        } 
    }

    static int get_new_id() {
        return (int)(Math.random()*100000);
    }

    public static void main(String[] args) {
        String info;
        int id;

        info = get_user_info();
        id = get_new_id();
        no_semi(info);
        write_info(id, info);
    }
}
