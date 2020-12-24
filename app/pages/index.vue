<template>
  <div>
    <v-row justify="center" align="center">
      <v-col cols="12" md="4">
        <v-select
          v-model="period"
          :items="periodItems"
          item-text="text"
          item-value="value"
          label="期間"
        />
      </v-col>
      <v-col cols="12" md="4">
        <v-select
          v-model="target"
          :items="targetItems"
          item-text="text"
          item-value="value"
          label="対象"
          clearable
        />
      </v-col>
      <v-col cols="12" md="4">
        <v-checkbox v-model="total" label="累計" />
      </v-col>
    </v-row>
    <v-row justify="center" align="center">
      <v-col cols="12" md="12">
        <canvas id="chart" width="400" height="400"></canvas>
      </v-col>
    </v-row>
  </div>
</template>

<script>
// import _ from 'lodash'
import moment from 'moment'
import csvtojson from 'csvtojson'
import Chart from 'chart.js'
/* eslint-disable */
// import { brewer, tableau, office } from 'chartjs-plugin-colorschemes'
import ChartPluginColorSchemes from 'chartjs-plugin-colorschemes'
/* eslint-enable */

export default {
  data: () => ({
    period: 'daily', // 期間
    target: null, // 対象
    total: false, // 累計
    chart: null,

    periodItems: [
      { text: '日別', value: 'daily' },
      { text: '週別', value: 'weekly' },
      { text: '月別', value: 'monthly' },
    ],
    targetItems: [
      { text: '地域', value: 'area' },
      { text: '年代', value: 'age' },
      { text: '性別', value: 'gender' },
    ],
    canvasID: 'chart',

    // CSV をパースした結果を格納する二次元配列
    dataRaw: [],
    /**
|     |                   |
|-----|-------------------|
|   0 | No                |
|   1 | リリース日        |
|   2 | 曜日              |
|   3 | 居住地            |
|   4 | 年代              |
|   5 | 性別              |
|   6 | 属性              |
|   7 | 備考              |
|   8 | 補足              |
|   9 | 退院              |
|  10 | 周囲の状況        |
|  11 | 濃厚接触者の状況  | 
|  12 | age_group         |
|  13 | sex_en            |
    **/
  }),
  watch: {
    period(v) {
      this.drawGraph()
    },
    target(v) {
      this.drawGraph()
    },
    total(v) {
      this.drawGraph()
    },
  },
  async mounted() {
    console.dir(this)
    await this.fetchData()
    this.drawGraph()
  },
  methods: {
    async fetchData() {
      // console.log(`location.origin=${location.origin}`)
      // const response = await this.$axios.get('/file/patients.csv')
      const url = `${location.origin}/file/patients.csv`
      const response = await this.$axios.get(url)
      console.log('result=', response.data)

      // see: https://openbase.io/js/csvtojson#browser-usage
      this.dataRaw = await csvtojson({
        output: 'csv',
      }).fromString(response.data)
      console.log('dataRaw=', this.dataRaw)
    },
    drawGraph() {
      // 日別 感染者数
      const data = {}
      const labelsX = []
      const labelsY = []
      for (const row of this.dataRaw) {
        // 期間 (=labelX)
        let labelX = row[1].split('T')[0] // 日付
        // if (this.period === 'daily')
        if (this.period === 'weekly') {
          labelX = moment(labelX, 'YYYY-MM-DD').format('GGGG-WW')
        }
        if (this.period === 'monthly') {
          labelX = moment(labelX, 'YYYY-MM-DD').format('YYYY-MM')
        }

        // 対象
        let labelY = 'none'
        if (this.target === 'area') labelY = row[3]
        if (this.target === 'age') labelY = row[12]
        if (this.target === 'gender') labelY = row[13]

        if (!(labelX in data)) data[labelX] = {}
        if (!(labelY in data[labelX])) data[labelX][labelY] = 0

        data[labelX][labelY]++

        if (!labelsX.includes(labelX)) labelsX.push(labelX)
        if (!labelsY.includes(labelY)) labelsY.push(labelY)
      }

      const datasets = []
      for (const labelY of labelsY.sort()) {
        const dataset = {
          label: null,
          data: [],
          borderWidth: 1,
        }

        // Y 軸 ラベル
        dataset.label = labelY
        if (this.target === null || this.target === undefined) {
          dataset.label = '患者数'
        }
        if (this.target === 'area') {
          dataset.label = labelY
        }
        if (this.target === 'age') {
          dataset.label = labelY === '0' ? '非公表' : labelY
        }
        if (this.target === 'gender') {
          dataset.label = labelY === '-' ? '非公表' : labelY
        }

        // X 軸 数値 設定
        let v = 0
        for (const labelX of labelsX.sort()) {
          // const v = (labelY in data[labelX]) ? data[labelX][labelY] : 0
          if (labelY in data[labelX]) {
            if (this.total) {
              v = v + data[labelX][labelY] // 累計
            } else {
              v = data[labelX][labelY]
            }
          }
          dataset.data.push(v)
        }

        datasets.push(dataset)
      }

      // see: https://www.chartjs.org/docs/latest/developers/api.html
      // if (this.chart !== null) this.chart.clear()
      // if (this.chart !== null) this.chart.reset()
      if (this.chart !== null) this.chart.destroy()
      this.chart = new Chart(this.canvasID, {
        type: 'bar',
        data: { labels: labelsX, datasets },
        options: {
          plugins: {
            colorschemes: {
              // see: https://nagix.github.io/chartjs-plugin-colorschemes/colorchart.html
              // scheme: 'brewer.Paired12'
              // scheme: 'tableau.HueCircle19'
              scheme: 'office.Excel16',
            },
          },
          scales: {
            xAxes: [{ stacked: true }],
            yAxes: [
              {
                stacked: true,
                // ticks: { beginAtZero: true }
              },
            ],
          },
        },
      })
    },
  },
}
</script>
