import 'dotenv/config'
import { PrismaClient } from './generated/prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'
import { parse } from 'csv-parse/sync'
import { readFileSync } from 'fs'
import { join } from 'path'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL })
const prisma = new PrismaClient({ adapter })

const CSV_PATH = join(__dirname, '..', 'csv', '31_tottori_all_20260731.csv')
const BATCH_SIZE = 1000

type Company = {
  corporate_number: string
  name: string
  name_kana: string
  address: string
  category: string
}

function readCompaniesFromCsv(path: string): Company[] {
  const buffer = readFileSync(path)
  const text = new TextDecoder('shift_jis').decode(buffer)
  const rows: string[][] = parse(text, {
    columns: false,
    skip_empty_lines: true,
  })

  return rows.map((row) => ({
    corporate_number: row[1],
    name: row[6],
    name_kana: row[28],
    address: `${row[9]}${row[10]}${row[11]}`,
    category: row[8],
  }))
}

async function main() {
  await prisma.company.deleteMany()

  const companies = readCompaniesFromCsv(CSV_PATH)

  for (let i = 0; i < companies.length; i += BATCH_SIZE) {
    const batch = companies.slice(i, i + BATCH_SIZE)
    await prisma.company.createMany({ data: batch })
    console.log(`Seeded ${Math.min(i + BATCH_SIZE, companies.length)} / ${companies.length}`)
  }
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
