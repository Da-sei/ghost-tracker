/*
  Warnings:

  - You are about to drop the column `nameKana` on the `Company` table. All the data in the column will be lost.
  - Added the required column `corporate_number` to the `Company` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name_kana` to the `Company` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Company" DROP COLUMN "nameKana",
ADD COLUMN     "corporate_number" TEXT NOT NULL,
ADD COLUMN     "name_kana" TEXT NOT NULL;
