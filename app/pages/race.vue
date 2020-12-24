<template>
  <v-row justify="center" align="center">
    <v-col cols="12" md="12">
      <div id="bar-chart-race"></div>
      <script type="module">
        import define from './script/bar-chart-race/index.js'
        import { Runtime, Library, Inspector } from './script/bar-chart-race/runtime.js'
        const runtime = new Runtime()
        // const main = runtime.module(define, Inspector.into(document.body))
        const main = runtime.module(define, Inspector.into(document.getElementById('bar-chart-race')))
      </script>
    </v-col>
  </v-row>
</template>

<script>
// import Logo from '~/components/Logo.vue'
// import VuetifyLogo from '~/components/VuetifyLogo.vue'
export default {
  // components: { Logo, VuetifyLogo, },
  head: {
    link: [
      { rel: 'stylesheet', type: 'text/css', href: '/style/inspector.css' },
    ],
  },
  mounted() {},
}
</script>
