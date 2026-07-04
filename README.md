# management-sandbox
## Shiny Application for Manage a Sandbox Environment

Developed using the package Shiny to create Web Applications in the R language, the main purpose of the "management-sandbox" app is to work as a Replication Data Hub to move Data from a Source Production Relational Database to a "mirror" environment called Sandbox.

This repository includes the code files that compose the Shiny Application, it's User Database and an Informational Example Data Base to test the functionalities of the Software.

## Introduction (Use case)

Supposing that we have a Production Environment that hosts an Analytical Database that stores enterprise Data, and a Sandbox Environment that mirrors the Production instance to allow Data teams, such as Data Analysts and Data Scientists, to run "heavy-weight" tests for developing Models and Explorations without competing with the operational processes for computational resources, the "management-sandbox" app offers a solution to manage the data replications needed to maintain the Sandbox ecosystem up to date againts any updates in the information that could occur in Production.

## The "Bank of Trust" example and the Analytical Model

Using the [BIAN Service Domain Landscape](https://bian.org/servicelandscape-12-0-0/views/view_51891.html) as a reference for Designing our Relational Data Model for a fictitional Banking Institution called "Bank of Trust", we can test our application on the following objects:
