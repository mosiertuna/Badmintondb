const url = 'http://localhost:8081/orders.html/';
var order = [];
var customer = null;
var dat = [];
var total = 0;
const state = ["Shopping" , "Confirmed", "Delivering", "Finished" , "Cancelled"];

checkCookie();

fetchOrders(); 


function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) == ' ') {
         c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
         return c.substring(name.length, c.length);
        }
        }
            return "";
        }
function checkCookie() {
    let user = getCookie("user");
            let ord = getCookie("order")
            if (user != "") {
              customer = user
            } 
          }
async function fetchOrders() {
  
    const res = await fetch(`${url}getOrders?customer_id=${customer}`,
        {
            method: 'GET',
            
            })
    const data = await res.json();
    order = data.info;
    console.log(data);
    displayOrders();
}

function displayOrders() {
    const orderListDiv = document.getElementById('order-list');
    orderListDiv.innerHTML = ''; // Clear previous content

    // Create a table to display orders
    const table = document.createElement('table');
    table.innerHTML = `
        <tr>
            <th>Order ID</th>
            <th>State</th>
            <th>Order Total</th>
            <th>Address</th>
            <th>Action</th>
        </tr>
    `;
     
    for(let i = 0; i<order.length; ++i){
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${order[i].order_id}</td>
            <td>${state[order[i].status]}</td>
            <td>${order[i].total_price}</td>
            <td>${`${order[i].address == null ? "" : order[i].address}` + " " + `${order[i].district == null ? "" : order[i].district}` + "" + order[i].city_name }</td>
            <td>
            <button class="view-btn" onclick="viewOrder(${order[i].order_id})">View</button>
            ${(order[i].status > 0 &&order[i].status < 2) ? `<button class="cancel-btn" onclick="cancelOrder(${order[i].order_id})">Cancel</button>` : ''}
            </td>
        `;
        table.appendChild(row);
    }

    orderListDiv.appendChild(table);
}

function cancelOrder(orderId) {
    fetch(`${url}cancelOrder?order_id=${orderId}`, {
        method: 'GET',
    })
    .then(response => {
        if (response.ok) {
            alert(`Order ${orderId} cancelled successfully!`);
            fetchOrders(); // Refresh orders after cancellation
        } else {
            alert(`Failed to cancel order ${orderId}. Please try again later.`);
        }
    })
    .catch(error => console.error('Error cancelling order:', error));
}

async function viewOrder(orderId) {
    const res = await fetch(`${url}getCart?order_id=${orderId}`, {
        method: 'GET',
    })
   
    const data = await res.json();
    dat = data.info;
    total = data.total_price[0].total_price;
    document.getElementById("info").textContent = "Information of order ID: " + orderId;
    viewInfo();
}


function viewInfo(){
    const itemsList = document.getElementById("items_list");
            itemsList.innerHTML = "";  // Clear previous items
        
            if (dat != null) {
                let tableContent = `
                    <table class = "cart-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Quantity</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                `;
        
                for (let i = 0; i < dat.length; ++i) {
                    tableContent += `
                        <tr>
                            <td>${dat[i].product_id}</td>
                            <td>${dat[i].product_name}</td>
                            <td>
                                ${dat[i].quantity}
                            </td>
                            <td>${dat[i].total}</td>
                        </tr>`;
                    
                }
        
                tableContent += `
                        </tbody>
                    </table>
                `;
        
                itemsList.innerHTML = tableContent;
        
                }
                document.getElementById("total_price").innerHTML = `<b><span>FINAL TOTAL</span> : ${total}`;
                
}