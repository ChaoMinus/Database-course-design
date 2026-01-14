<!-- 修改 UserShop.vue 文件，添加搜索功能 -->
<template>
    <div>
        <div class="header">
            欢迎点餐
        </div>
        <div class="body">
            <!-- 搜索区域 -->
            <div class="search-area">
                <el-input
                    v-model="searchKeyword"
                    placeholder="搜索店铺名称"
                    clearable
                    style="width: 300px; margin-bottom: 20px;"
                    @keyup.enter="handleSearch"
                    @clear="handleSearch"
                >
                    <el-button slot="append" icon="el-icon-search" @click="handleSearch"></el-button>
                </el-input>
                
                <el-tag v-if="searchKeyword" type="info" closable @close="clearSearch">
                    搜索: {{ searchKeyword }} ({{ filteredTableData.length }} 个结果)
                </el-tag>
            </div>
            
            <el-table :data="filteredTableData" style="width: 100%" class="table" border :loading="loading">
                <!-- 原有列保持不变 -->
                <el-table-column prop="shop_name" label="店铺名称" width="200" align="center">
                </el-table-column>
                <el-table-column prop="price" label="产品单价" width="200" align="center">
                </el-table-column>
                <el-table-column prop="sale" label="月销量" width="200" align="center">
                </el-table-column>
                <el-table-column prop="operate" label="操作" width="208" align="center">
                    <template slot-scope="scope">
                        <el-button icon="el-icon-plus" size="small" type="success" @click="showdia(scope.row)">订餐
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
            
            <!-- 分页 -->
            <div v-if="filteredTableData.length > 10" class="pagination-area">
                <el-pagination
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                    :current-page="currentPage"
                    :page-sizes="[10, 20, 50]"
                    :page-size="pageSize"
                    layout="total, sizes, prev, pager, next, jumper"
                    :total="filteredTableData.length"
                >
                </el-pagination>
            </div>

            <!-- 原有对话框保持不变 -->
            <el-dialog title="订餐表单" :visible.sync="dialog" class="dialog" width="40%">
                <!-- 原有代码保持不变 -->
            </el-dialog>
        </div>
    </div>
</template>

<script>
export default {
    created() {
        this.getdata();
    },
    data() {
        return {
            tableData: [],
            filteredTableData: [],
            searchKeyword: '',
            loading: false,
            currentPage: 1,
            pageSize: 10,
            
            // 原数据保持不变
            dialog: false,
            form: {
                shop_name: '',
                order_money: '',
                order_way: '',
                cons_name: '',
                cons_addre: '',
            }
        }
    },
    computed: {
        // 分页后的数据
        pagedTableData() {
            const start = (this.currentPage - 1) * this.pageSize;
            const end = start + this.pageSize;
            return this.filteredTableData.slice(start, end);
        }
    },
    methods: {
        async getdata() {
            this.loading = true;
            try {
                const res = await this.$axios.get("/api/user/shop");
                console.log(res.data);
                if (res.data.status == 200) {
                    this.tableData = res.data.tabledata;
                    this.filteredTableData = [...this.tableData];
                }
            } catch (error) {
                console.error('获取店铺数据失败:', error);
                this.$message.error('获取店铺数据失败');
            } finally {
                this.loading = false;
            }
        },
        
        // 搜索功能
        handleSearch() {
            if (!this.searchKeyword.trim()) {
                this.filteredTableData = [...this.tableData];
                this.currentPage = 1;
                return;
            }
            
            const keyword = this.searchKeyword.toLowerCase();
            this.filteredTableData = this.tableData.filter(shop => 
                shop.shop_name.toLowerCase().includes(keyword)
            );
            this.currentPage = 1; // 搜索后回到第一页
        },
        
        // 清空搜索
        clearSearch() {
            this.searchKeyword = '';
            this.filteredTableData = [...this.tableData];
            this.currentPage = 1;
        },
        
        // 分页相关方法
        handleSizeChange(val) {
            this.pageSize = val;
            this.currentPage = 1;
        },
        
        handleCurrentChange(val) {
            this.currentPage = val;
        },
        
        // 原有方法保持不变
        showdia(row) {
            this.form.shop_name = row.shop_name;
            this.form.order_money = row.price;
            this.dialog = true;
        },
        add() {
            this.$axios.post("/api/user/addorder", this.form).then((res) => {
                console.log(res.data);
                if (res.data.status == 200) {
                    this.$message({
                        message: "成功下单",
                        type: "success"
                    })
                    this.dialog = false;
                    this.getdata(); // 刷新数据，更新销量
                }
            })
        }
    }
}
</script>

<style scoped>
.header {
    width: 100%;
    height: 10%;
    text-align: center;
    line-height: 64px;
    font-size: 20px;
    font-weight: 800;
    border-bottom: 1px solid #e3e3e3;
}

.body {
    width: 70%;
    margin: auto;
    margin-top: 30px;
}

.search-area {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.pagination-area {
    margin-top: 20px;
    display: flex;
    justify-content: center;
}
</style>