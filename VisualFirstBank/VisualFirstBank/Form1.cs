using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace VisualFirstBank
{
    public partial class Form1 : Form
    {
        SqlConnection con;
        SqlDataAdapter creditCardsAdapter, purchasesAdapter;
        DataSet dset;
        SqlCommandBuilder creditCardsCommandBuilder;
        BindingSource creditCardsBindingSource, purchasesBindingSource;
        string queryCreditCards = "SELECT * FROM CreditCards";
        string queryPurchases = "SELECT * FROM Purchases";
        string connectionString = "Data Source=Tudoryka\\SQLEXPRESS;Initial Catalog=FirstBank;Integrated Security=True";

        public Form1()
        {
            InitializeComponent();
            FillData();
        }

        private void FillData()
        {
            // Initialize the Sql Connection
            con = new SqlConnection(connectionString);

            creditCardsAdapter = new SqlDataAdapter(queryCreditCards, con);
            purchasesAdapter = new SqlDataAdapter(queryPurchases, con);

            dset = new DataSet();
            creditCardsAdapter.Fill(dset, "CreditCards");
            purchasesAdapter.Fill(dset, "Purchases");

            // Preparing for insert, update and delete commands
            creditCardsCommandBuilder = new SqlCommandBuilder(purchasesAdapter);

            // DataRelation
            dset.Relations.Add("CardPurchases",
                dset.Tables["CreditCards"].Columns["card_id"],
                dset.Tables["Purchases"].Columns["card_id"]);

            // Binding sources
            creditCardsBindingSource = new BindingSource();
            creditCardsBindingSource.DataSource = dset.Tables["CreditCards"];
            purchasesBindingSource = new BindingSource(creditCardsBindingSource, "CardPurchases");

            this.dataGridView1.DataSource = purchasesBindingSource;
            this.dataGridView2.DataSource = creditCardsBindingSource;

            creditCardsCommandBuilder.GetUpdateCommand();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            purchasesAdapter.Update(dset, "Purchases");
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }
    }
}
