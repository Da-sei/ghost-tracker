import { Injectable } from '@nestjs/common';
import { PrismaClient } from '../../../prisma/generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { ComapanyDto } from './dto/company.dto';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

@Injectable()
export class CompaniesService {

    async getCompanies(): Promise<ComapanyDto[]> {
        return await prisma.company.findMany();
    }

    async getCompaniesByName(name: string): Promise<ComapanyDto[]> {
        return await prisma.company.findMany({
            where: {
                name: {
                    contains: name,
                    mode: 'insensitive'
                }
            }
        });
    }
}
