import { Telegraf } from 'telegraf'
import botData from './index.js'
const bot = new Telegraf("1855467240:AAF01jBPbI_MPH88VCevZGBk-uHrz6SwBBo")
let data = {}
returnData()
async function returnData() {
    data = await botData()
    console.log(data.profit)
    bot.command('profit', (ctx) => {
        ctx.reply(data.profit)
    })
    bot.start(Telegraf.reply(data))
    bot.help((ctx) => ctx.reply('Send me a sticker'))
    bot.on('sticker', (ctx) => ctx.reply('👍'))
    bot.hears('hi', (ctx) => ctx.reply('Hey there'))
    bot.launch()
    //bot.stop("stopping");
    // Enable graceful stop
    process.once('SIGINT', () => bot.stop('SIGINT'))
    process.once('SIGTERM', () => bot.stop('SIGTERM'))


}

