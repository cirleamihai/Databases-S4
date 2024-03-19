using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;

namespace FirsBankNameSpace
{
    internal class FirstBank
    {
        static void Main(string[] args)
        {
            string newConString = "Data Source=Tudoryka\\SQLEXPRESS;Initial Catalog=FirstBank;Integrated Security=True";
            SqlConnection con = new SqlConnection(newConString);

            FirstBank.UseAdapter(con);

            Console.ReadKey(true);
        }

        static void sqlCommandStr(SqlConnection con)
        {
            con.Open();

            Console.WriteLine("Connection Open !");

            string sqlString = "SELECT * FROM CreditCards";
            SqlCommand cmd = new SqlCommand(sqlString, con);

            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    Console.WriteLine("{0}, {1}", reader[0], reader[1]);
                }
            }
            // Using DataSets and DataAdapters
            con.Close();
        }

        static void UseAdapter(SqlConnection con)
        {
            string sqlString = "SELECT * FROM CreditCards";
            SqlDataAdapter adapter = new SqlDataAdapter(sqlString, con);
            SqlCommandBuilder sqlCommandBuilder = new SqlCommandBuilder(adapter);
            DataSet ds = new DataSet();
            adapter.Fill(ds, "CreditCards");

            foreach (DataRow row in ds.Tables["CreditCards"].Rows)
            {
                Console.WriteLine("{0}, {1}/{2}, {3}", row["number"], row["exp_month"], row["exp_year"], row["cvv"]);
            }
        }
    }
}
