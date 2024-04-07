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
using System.Configuration;

namespace VisualFirstBank
{
    public partial class Form1 : Form
    {
        SqlConnection con;
        SqlDataAdapter singleTableAdapter, manyTableAdapter;
        DataSet dset;
        SqlCommandBuilder singleTableBuilder;
        BindingSource singleTableSource, manyTableSource;
        String singleTable = ConfigurationManager.AppSettings["SingleTableAdapter"];
        String manyTable = ConfigurationManager.AppSettings["ManyTableAdapter"];
        String singleTableColumnName = ConfigurationManager.AppSettings["SingleTableColumnName"];
        String manyTableColumnName = ConfigurationManager.AppSettings["ManyTableColumnName"];
        String querySingleTable;
        String queryManyTable;
        String connectionString = "Data Source=Tudoryka\\SQLEXPRESS;Initial Catalog=FirstBank;Integrated Security=True";

        public Form1()
        {
            querySingleTable = $"SELECT * FROM {singleTable}";
            queryManyTable = $"SELECT * FROM {manyTable}";

            InitializeComponent();
            FillData();
        }

        private void FillData()
        {
            // Initialize the Sql Connection
            con = new SqlConnection(connectionString);

            singleTableAdapter = new SqlDataAdapter(querySingleTable, con);
            manyTableAdapter = new SqlDataAdapter(queryManyTable, con);

            dset = new DataSet();
            singleTableAdapter.Fill(dset, singleTable);
            manyTableAdapter.Fill(dset, manyTable);

            // Preparing for insert, update and delete commands
            singleTableBuilder = new SqlCommandBuilder(manyTableAdapter);

            String relationshipName = $"FK_{singleTable}{manyTable}";
            // DataRelation
            dset.Relations.Add(relationshipName,
                dset.Tables[singleTable].Columns[singleTableColumnName],
                dset.Tables[manyTable].Columns[manyTableColumnName]);

            // Binding sources
            singleTableSource = new BindingSource(dset, singleTable);
            manyTableSource = new BindingSource(singleTableSource, relationshipName);

            this.dataGridView1.DataSource = manyTableSource;
            this.dataGridView2.DataSource = singleTableSource;

            singleTableBuilder.GetUpdateCommand();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            manyTableAdapter.Update(dset, manyTable);
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }
    }
}
