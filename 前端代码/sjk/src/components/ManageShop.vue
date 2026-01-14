<template>
    <div>
        <div class="header">
            店铺管理
        </div>
        <div class="body">
            <!-- 查询和统计区域 -->
            <div class="search-stat-area">
                <!-- 查询区域 -->
                <div class="search-area">
                    <el-input
                        v-model="searchKeyword"
                        placeholder="输入店铺名称搜索"
                        clearable
                        style="width: 300px; margin-right: 20px;"
                        @keyup.enter="handleSearch"
                        @clear="handleSearch"
                    >
                        <el-button slot="append" icon="el-icon-search" @click="handleSearch"></el-button>
                    </el-input>
                </div>
                
                <!-- 统计区域 -->
                <div class="stat-area">
                    <el-button 
                        type="primary" 
                        icon="el-icon-data-analysis" 
                        @click="showRevenueStats"
                    >
                        查看营业额统计
                    </el-button>
                    
                    <el-button 
                        type="success" 
                        icon="el-icon-money" 
                        @click="showPlatformRevenue"
                    >
                        平台总营业额
                    </el-button>
                </div>
            </div>

            <!-- 店铺列表 -->
            <el-table 
                :data="filteredTableData" 
                style="width: 100%" 
                class="table" 
                border
                :loading="loading"
            >
                <el-table-column prop="shop_name" label="店铺名称" width="200" align="center">
                </el-table-column>
                <el-table-column prop="price" label="产品单价" width="120" align="center">
                </el-table-column>
                <el-table-column prop="sale" label="月销量" width="120" align="center">
                </el-table-column>
                <el-table-column prop="revenue" label="营业额(元)" width="150" align="center">
                    <template slot-scope="scope">
                        {{ scope.row.revenue || 0 }}
                    </template>
                </el-table-column>
                <el-table-column prop="operate" label="操作" width="200" align="center">
                    <template slot-scope="scope">
                        <el-button size="small" type="warning" @click="showdia_chg(scope.row)">修改
                        </el-button>

                        <el-button size="small" type="danger" @click="showdia_dlt(scope.row)">删除
                        </el-button>
                    </template>
                </el-table-column>
                <el-table-column width="120" align="center">
                    <template slot="header">
                        <el-button icon="el-icon-plus" size="small" type="success" @click="showdia_add()">添加店铺
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 店铺营业额统计对话框 -->
            <el-dialog 
                title="店铺营业额统计" 
                :visible.sync="revenueDialogVisible" 
                width="70%"
                :close-on-click-modal="false"
            >
                <el-table 
                    :data="revenueStats" 
                    style="width: 100%" 
                    border
                    :summary-method="getShopSummaries"
                    show-summary
                >
                    <el-table-column prop="shop_name" label="店铺名称" width="200" align="center"></el-table-column>
                    <el-table-column prop="order_count" label="订单数量" width="150" align="center"></el-table-column>
                    <el-table-column prop="total_revenue" label="总营业额(元)" width="150" align="center">
                        <template slot-scope="scope">
                            {{ scope.row.total_revenue.toFixed(2) }}
                        </template>
                    </el-table-column>
                    <el-table-column prop="avg_order_value" label="平均订单金额(元)" width="180" align="center">
                        <template slot-scope="scope">
                            {{ scope.row.avg_order_value.toFixed(2) }}
                        </template>
                    </el-table-column>
                </el-table>
                
                <!-- 图表展示 -->
                <div v-if="revenueStats.length > 0" style="margin-top: 30px;">
                    <div style="text-align: center; font-weight: bold; margin-bottom: 20px;">店铺营业额分布</div>
                    <div id="revenueChart" style="width: 100%; height: 400px;"></div>
                </div>
                
                <div slot="footer" class="dialog-footer">
                    <el-button @click="revenueDialogVisible = false">关闭</el-button>
                    <el-button type="primary" @click="exportRevenueData">导出数据</el-button>
                </div>
            </el-dialog>

            <!-- 平台总营业额对话框 -->
            <el-dialog 
                title="平台总营业额统计" 
                :visible.sync="platformDialogVisible" 
                width="50%"
            >
                <el-card v-if="platformStats" class="platform-stats-card">
                    <div class="stat-item">
                        <span class="stat-label">总订单数：</span>
                        <span class="stat-value highlight">{{ platformStats.total_orders }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">平台总营业额：</span>
                        <span class="stat-value highlight money">¥{{ platformStats.total_revenue.toFixed(2) }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">平均订单金额：</span>
                        <span class="stat-value">¥{{ platformStats.avg_order_value.toFixed(2) }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">统计时间：</span>
                        <span class="stat-value">{{ platformStats.calculate_time }}</span>
                    </div>
                </el-card>
                
                <!-- 简单趋势说明 -->
                <div v-if="revenueStats.length > 0" style="margin-top: 20px;">
                    <div style="font-weight: bold; margin-bottom: 10px;">营业额前三店铺：</div>
                    <el-tag 
                        v-for="(shop, index) in top3Shops" 
                        :key="shop.shop_name"
                        :type="index === 0 ? 'success' : index === 1 ? 'warning' : 'info'"
                        style="margin-right: 10px; margin-bottom: 5px;"
                    >
                        {{ index + 1 }}. {{ shop.shop_name }} (¥{{ shop.total_revenue.toFixed(2) }})
                    </el-tag>
                </div>
                
                <div slot="footer" class="dialog-footer">
                    <el-button @click="platformDialogVisible = false">关闭</el-button>
                    <el-button type="success" @click="refreshPlatformStats">刷新数据</el-button>
                </div>
            </el-dialog>

            <el-dialog title="添加店铺" :visible.sync="dia_add" width="30%">
                <el-form ref="add_form" :model="add_form" label-width="100px" :rules="add_form_rules">
                    <el-form-item label="店铺名称：" prop="shop_name">
                        <el-input v-model="add_form.shop_name"></el-input>
                    </el-form-item>
                    <el-form-item label="产品单价：" prop="price">
                        <el-input v-model="add_form.price"></el-input>
                    </el-form-item>
                    <el-form-item label="月销量：" prop="m_sale_v">
                        <el-input v-model="add_form.m_sale_v"></el-input>
                    </el-form-item>
                </el-form>
                <div style="text-align: center;">
                    <el-button type="primary" @click="addshop()">
                        添加
                    </el-button>
                </div>
            </el-dialog>

            <el-dialog title="修改店铺" :visible.sync="dia_chg" width="30%">
                <el-form ref="form" :model="chg_form" label-width="100px">
                    <el-form-item label="店铺名称：">
                        <span>{{ chg_form.shop_name }}</span>
                    </el-form-item>
                    <el-form-item label="产品单价：">
                        <el-input v-model="chg_form.price"></el-input>
                    </el-form-item>
                    <el-form-item label="月销量：">
                        <el-input v-model="chg_form.m_sale_v"></el-input>
                    </el-form-item>
                </el-form>
                <div style="text-align: center;">
                    <el-button type="primary" @click="changeshop()">
                        修改
                    </el-button>
                </div>
            </el-dialog>
            
            <el-dialog title="删除店铺" :visible.sync="dia_dlt" width="30%">
                <div>
                    确定删除此店铺吗？
                </div>
                <div style="text-align: center;">
                    <el-button type="primary" @click="deleteshop()">
                        确定
                    </el-button>
                </div>
            </el-dialog>
        </div>
    </div>
</template>

<script>
// 引入echarts用于图表展示
import * as echarts from 'echarts';

export default {
    created() {
        this.getdata();
        // 初始化时加载营业额数据
        this.loadShopRevenue();
    },
    data() {
        return {
            tableData: [],
            filteredTableData: [],
            shopRevenueMap: {}, // 店铺营业额映射
            searchKeyword: '',
            loading: false,
            
            // 营业额统计相关
            revenueDialogVisible: false,
            revenueStats: [],
            platformDialogVisible: false,
            platformStats: null,
            
            // 原对话框相关
            dia_add: false,
            dia_chg: false,
            dia_dlt: false,
            add_form: {
                shop_name: '',
                price: '',
                m_sale_v: '',
                action: "add",
            },
            chg_form: {
                shop_name: '',
                price: '',
                m_sale_v: '',
                action: "change",
            },
            want_delete: '',
            add_form_rules: {
                shop_name: [{ required: true, message: '必填项', trigger: 'blur' }],
                price: [{ required: true, message: '必填项', trigger: 'blur' }],
                m_sale_v: [{ required: true, message: '必填项', trigger: 'blur' }]
            },
            chartInstance: null
        }
    },
    computed: {
        // 营业额前三的店铺
        top3Shops() {
            return [...this.revenueStats]
                .sort((a, b) => b.total_revenue - a.total_revenue)
                .slice(0, 3);
        }
    },
    watch: {
        searchKeyword(newVal) {
            if (!newVal) {
                this.filteredTableData = [...this.tableData];
            }
        }
    },
    methods: {
        async getdata() {
            this.loading = true;
            try {
                const res = await this.$axios.get("/api/manager/shop");
                console.log(res.data);
                if (res.data.status == 200) {
                    this.tableData = res.data.tabledata;
                    this.filteredTableData = [...this.tableData];
                    
                    // 合并营业额数据
                    this.mergeRevenueData();
                }
            } catch (error) {
                console.error('获取店铺数据失败:', error);
                this.$message.error('获取店铺数据失败');
            } finally {
                this.loading = false;
            }
        },
        
        async loadShopRevenue() {
            try {
                // 方法1：调用后端API获取营业额数据
                const res = await this.$axios.get("/api/manager/shop/revenue");
                console.log("API返回的营业额数据:", res.data);
                
                if (res.data.status == 200) {
                    // 转换为映射，便于查找
                    this.shopRevenueMap = {};
                    res.data.revenue_stats.forEach(shop => {
                        this.shopRevenueMap[shop.shop_name] = shop;
                    });
                    console.log("营业额映射表:", this.shopRevenueMap);
                    
                    // 合并数据
                    this.mergeRevenueData();
                } else {
                    // 如果API调用失败，使用前端计算
                    this.calculateRevenueFromTableData();
                }
            } catch (error) {
                console.error('API调用失败，使用本地计算:', error);
                // API调用失败时，使用前端计算
                this.calculateRevenueFromTableData();
            }
        },

        // 新增：基于表格数据计算营业额（单价×销量）
        calculateRevenueFromTableData() {
            this.shopRevenueMap = {};
            
            // 计算营业额 = 单价 × 销量
            this.tableData.forEach(shop => {
                const revenue = shop.price * shop.sale;
                this.shopRevenueMap[shop.shop_name] = {
                    shop_name: shop.shop_name,
                    total_revenue: revenue,
                    order_count: shop.sale
                };
                
                console.log(`计算 ${shop.shop_name}: ${shop.price} × ${shop.sale} = ${revenue}`);
            });
            
            // 合并数据
            this.mergeRevenueData();
        },

        // 修改 mergeRevenueData 方法，添加调试信息
        mergeRevenueData() {
            if (this.tableData.length > 0) {
                console.log("开始合并营业额数据...");
                console.log("当前店铺列表:", this.tableData);
                console.log("营业额映射:", this.shopRevenueMap);
                
                this.tableData.forEach(shop => {
                    const revenueData = this.shopRevenueMap[shop.shop_name];
                    if (revenueData) {
                        console.log(`${shop.shop_name} 的营业额: ${revenueData.total_revenue}`);
                        // 使用 $set 确保响应式更新
                        this.$set(shop, 'revenue', revenueData.total_revenue);
                    } else {
                        console.log(`${shop.shop_name} 没有营业额数据，使用0`);
                        this.$set(shop, 'revenue', 0);
                    }
                });
                
                // 更新过滤后的数据
                this.filteredTableData = [...this.tableData];
                console.log("合并后的表格数据:", this.filteredTableData);
            }
        },
        
        // 搜索功能
        handleSearch() {
            if (!this.searchKeyword.trim()) {
                this.filteredTableData = [...this.tableData];
                return;
            }
            
            const keyword = this.searchKeyword.toLowerCase();
            this.filteredTableData = this.tableData.filter(shop => 
                shop.shop_name.toLowerCase().includes(keyword)
            );
        },
        
        // 显示营业额统计
        async showRevenueStats() {
            try {
                this.revenueDialogVisible = true;
                const res = await this.$axios.get("/api/manager/shop/revenue/detail");
                if (res.data.status == 200) {
                    this.revenueStats = res.data.revenue_stats;
                    
                    // 渲染图表
                    this.$nextTick(() => {
                        this.renderRevenueChart();
                    });
                }
            } catch (error) {
                console.error('获取营业额统计失败:', error);
                this.$message.error('获取营业额统计失败');
            }
        },
        
        // 显示平台总营业额
        async showPlatformRevenue() {
            try {
                this.platformDialogVisible = true;
                await this.refreshPlatformStats();
            } catch (error) {
                console.error('获取平台营业额失败:', error);
                this.$message.error('获取平台营业额失败');
            }
        },
        
        // 刷新平台统计数据
        async refreshPlatformStats() {
            const res = await this.$axios.get("/api/manager/platform/revenue");
            if (res.data.status == 200) {
                this.platformStats = {
                    ...res.data.platform_stats,
                    calculate_time: new Date().toLocaleString()
                };
            }
        },
        
        // 渲染营业额图表
        renderRevenueChart() {
            if (!this.revenueStats || this.revenueStats.length === 0) return;
            
            // 销毁之前的图表实例
            if (this.chartInstance) {
                this.chartInstance.dispose();
            }
            
            const chartDom = document.getElementById('revenueChart');
            if (!chartDom) return;
            
            this.chartInstance = echarts.init(chartDom);
            
            // 准备数据
            const shopNames = this.revenueStats.map(shop => shop.shop_name);
            const revenues = this.revenueStats.map(shop => shop.total_revenue);
            
            const option = {
                tooltip: {
                    trigger: 'axis',
                    formatter: '{b}: ¥{c}'
                },
                xAxis: {
                    type: 'category',
                    data: shopNames,
                    axisLabel: {
                        rotate: 45,
                        interval: 0
                    }
                },
                yAxis: {
                    type: 'value',
                    name: '营业额(元)'
                },
                series: [{
                    data: revenues,
                    type: 'bar',
                    itemStyle: {
                        color: function(params) {
                            const colorList = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc'];
                            return colorList[params.dataIndex % colorList.length];
                        }
                    },
                    label: {
                        show: true,
                        position: 'top',
                        formatter: '¥{c}'
                    }
                }],
                grid: {
                    left: '3%',
                    right: '4%',
                    bottom: '15%',
                    containLabel: true
                }
            };
            
            this.chartInstance.setOption(option);
            
            // 响应窗口大小变化
            window.addEventListener('resize', () => {
                if (this.chartInstance) {
                    this.chartInstance.resize();
                }
            });
        },
        
        // 表格合计行计算方法
        getShopSummaries(param) {
            const { columns, data } = param;
            const sums = [];
            columns.forEach((column, index) => {
                if (index === 0) {
                    sums[index] = '合计';
                    return;
                }
                if (index === 1) {
                    sums[index] = this.revenueStats.length;
                    return;
                }
                if (column.property === 'total_revenue') {
                    const values = data.map(item => Number(item[column.property]));
                    if (!values.every(value => isNaN(value))) {
                        sums[index] = values.reduce((prev, curr) => {
                            const value = Number(curr);
                            if (!isNaN(value)) {
                                return prev + value;
                            } else {
                                return prev;
                            }
                        }, 0).toFixed(2);
                        sums[index] += ' 元';
                    } else {
                        sums[index] = 'N/A';
                    }
                } else if (column.property === 'avg_order_value') {
                    const revenues = data.map(item => Number(item.total_revenue));
                    const counts = data.map(item => Number(item.order_count));
                    
                    const totalRevenue = revenues.reduce((a, b) => a + b, 0);
                    const totalOrders = counts.reduce((a, b) => a + b, 0);
                    
                    if (totalOrders > 0) {
                        sums[index] = (totalRevenue / totalOrders).toFixed(2);
                        sums[index] += ' 元';
                    } else {
                        sums[index] = 'N/A';
                    }
                } else {
                    sums[index] = 'N/A';
                }
            });
            
            return sums;
        },
        
        // 查看店铺订单
        viewShopOrders(shop) {
            this.$message.info(`查看 ${shop.shop_name} 的订单详情功能正在开发中`);
            // 这里可以跳转到订单管理页面并筛选该店铺的订单
        },
        
        // 导出营业额数据
        exportRevenueData() {
            const dataStr = JSON.stringify(this.revenueStats, null, 2);
            const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
            
            const exportFileDefaultName = `店铺营业额统计_${new Date().toLocaleDateString()}.json`;
            
            const linkElement = document.createElement('a');
            linkElement.setAttribute('href', dataUri);
            linkElement.setAttribute('download', exportFileDefaultName);
            linkElement.click();
            
            this.$message.success('数据导出成功');
        },
        
        // 原方法保持不变
        showdia_add() {
            this.dia_add = true;
        },
        addshop() {
            this.$refs.add_form.validate(valid => {
                if (!valid) return;
                
                this.$axios.post("/api/manager/shop", this.add_form).then((res) => {
                    console.log(res.data);
                    if (res.data.status == 200) {
                        this.$message({
                            message: "添加成功",
                            type: "success"
                        })
                        this.dia_add = false;
                        this.getdata();
                        this.loadShopRevenue(); // 重新加载营业额数据
                    } else {
                        this.$message({
                            message: res.data.msg,
                            type: "error"
                        })
                    }
                })
            })
        },
        showdia_chg(row) {
            this.chg_form.shop_name = row.shop_name;
            this.chg_form.price = row.price;
            this.chg_form.m_sale_v = row.sale;
            this.dia_chg = true;
        },
        changeshop() {
            this.$axios.post("/api/manager/shop", this.chg_form).then((res) => {
                console.log(res.data);
                if (res.data.status == 200) {
                    this.$message({
                        message: "修改成功",
                        type: "success"
                    })
                    this.dia_chg = false;
                    this.getdata();
                    this.loadShopRevenue(); // 重新加载营业额数据
                }
            })
        },
        showdia_dlt(row) {
            this.want_delete = row.shop_name;
            this.dia_dlt = true;
        },
        deleteshop() {
            this.$axios.delete("/api/manager/shop", { data: { want_delete: this.want_delete } }).then((res) => {
                if (res.data.status == 200) {
                    this.$message({
                        message: res.data.msg,
                        type: "success"
                    })
                    this.getdata()
                    this.loadShopRevenue(); // 重新加载营业额数据
                    this.dia_dlt = false;
                }
            })
        }
    },
    
    // 组件销毁前清理图表实例
    beforeDestroy() {
        if (this.chartInstance) {
            this.chartInstance.dispose();
            this.chartInstance = null;
        }
        window.removeEventListener('resize', () => {});
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
    width: 90%;
    margin: auto;
    margin-top: 30px;
}

.search-stat-area {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    background-color: #f5f7fa;
    border-radius: 8px;
}

.search-area, .stat-area {
    display: flex;
    align-items: center;
}

.stat-area .el-button {
    margin-left: 10px;
}

.platform-stats-card {
    padding: 20px;
}

.stat-item {
    margin-bottom: 15px;
    font-size: 16px;
}

.stat-label {
    font-weight: bold;
    color: #606266;
}

.stat-value {
    margin-left: 10px;
}

.stat-value.highlight {
    color: #409EFF;
    font-weight: bold;
}

.stat-value.money {
    color: #67C23A;
    font-size: 20px;
}

.dialog-footer {
    text-align: center;
}

/* 响应式调整 */
@media screen and (max-width: 1200px) {
    .search-stat-area {
        flex-direction: column;
        align-items: stretch;
    }
    
    .search-area, .stat-area {
        margin-bottom: 15px;
        justify-content: center;
    }
}
</style>