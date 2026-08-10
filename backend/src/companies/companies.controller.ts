import { Controller, Get, Inject, Query } from '@nestjs/common';
import { CompaniesService } from './companies.service';
import { ComapanyDto } from './dto/company.dto';

@Controller('companies')
export class CompaniesController {
    constructor(@Inject(CompaniesService) private readonly companiesService: CompaniesService) {}

    @Get()
    async getCompanies(@Query('name') name?: string): Promise<ComapanyDto[]> {
        if (name) {
            return await this.companiesService.getCompaniesByName(name);
        }
        return await this.companiesService.getCompanies();
    }
}
