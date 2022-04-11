import { HttpClient } from '@angular/common/http';
import { Component, Inject, OnInit } from '@angular/core';

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.css']
})
export class ProductsComponent implements OnInit {
  public salesOrders: SalesOrderHeader[] = [];

  constructor(http: HttpClient, @Inject('BASE_URL') baseUrl: string) {
    http.get<SalesOrderHeader[]>(baseUrl + 'api/salesorder').subscribe(result => {
      this.salesOrders = result;
    }, error => console.error(error));
  }

  ngOnInit(): void {
  }

}

interface SalesOrderHeader {
  salesOrderNumber: string;
  orderDate: string;
  subTotal: number;
  totalDue: number;
}
