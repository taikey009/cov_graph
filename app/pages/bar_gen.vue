<template>
  <v-row justify="center" align="center">
    <v-col cols="12" md="12">
      <canvas id="chart" width="400" height="400"></canvas>
    </v-col>
  </v-row>
</template>

<script>
// import _ from 'lodash'
// import moment from 'moment'
import csvtojson from 'csvtojson'
import Chart from 'chart.js'
import Chart2 from 'chart.js'
import { brewer } from 'chartjs-plugin-colorschemes'

export default {
  data: () => ({
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
  async mounted() {
    console.dir(this)
    await this.fetchData()
    this.drawGraph()
  },
  methods: {
    async fetchData() {
      const response = await this.$axios.get('/file/patients.csv')
      console.log('result=', response.data)

      // see: https://openbase.io/js/csvtojson#browser-usage
      this.dataRaw = await csvtojson({ output: 'csv' }).fromString(response.data)
      console.log('dataRaw=', this.dataRaw)
    },
    drawGraph() {
      // 日別 感染者数
      const data = {}
      for (const row of this.dataRaw) {
        const d = row[1].split('T')[0] // 日付
        console.log('d=', d)
        if (!(d in data)) data[d] = 0
        data[d]++
      }
      const labels = Object.keys(data).sort()
      console.log('labels=', labels)

      const datasetsMale = []
      datasetsMale[0] = {
        label: '男性',
        data: [],
        borderWidth: 1,
      }

      const datasetsFemale = []
      datasetsFemale[0] = {
        label: '女性',
        data: [],
        borderWidth: 1,
      }

      const datasets = []
      datasets[0] = {
        label: '日別',
        data: [],
        borderWidth: 1,
      }

      for (const key of labels) {
        datasets[0].data.push(data[key])
        datasetsMale[0].data.push(data[key])
        datasetsFemale[0].data.push(data[key])
      }
      console.log('sets=', datasets)
      console.log('male=', datasetsMale)
      console.log('female=', datasetsFemale)

      new Chart(this.canvasID, {
        type: 'bar',
//        data: { labels, datasets },
//        data: { labels, datasetsMale },

        data: {
          labels,
//          datasets,
          datasets: [{
                label: datasetsMale.label,
                data: datasetsMale.data,
              }],
//              }, {
//                label: '女性',
//                datasets,
//              }],
        },

        options: {
          plugins: {
            colorschemes: {
              // see: https://nagix.github.io/chartjs-plugin-colorschemes/colorchart.html
              scheme: 'brewer.Paired12'
            }
          },
          scales: {
            xAxes: [ { stacked: true } ],
            yAxes: [ { stacked: true } ],
          },
          title: {
            display: true,
            text: '日毎の新型コロナ感染者数',
          },
          legend: {
            display: true,
            labels: {
              fontColor: 'rgb(0, 0, 0)'
            }
          }
        }
      })
    },
  },
}
</script>
