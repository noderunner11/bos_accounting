import shell from 'shelljs'
import fs from 'fs'

async function parseData() {

  shell.exec('./bos_accounting.sh');

  try {
    const data = fs.readFileSync('./bos_accounting.log', 'utf8')
    const parse = data.split(' ');
    const botData = {
      date: parse[0],
      time: parse[1],
      localBalance: parse[2],
      weeklyFor: parse[3],
      percent: parse[4],
      earnedPpm: parse[5],
      paidPpm: parse[6],
      netPpm: parse[7],
      earnedSats: parse[8],
      paidSats: parse[9],
      profit: parse[10]
    }
    return botData
  } catch (err) {
    console.error(err)
  }

}
export default parseData