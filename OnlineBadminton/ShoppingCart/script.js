const url = 'http://localhost:8081/cart.html/';
var dat = [];
var vdat = [];
var curr_v = [];
var total = 0;
var changeColor = 0;
document.getElementById("home").addEventListener('click', () => {
    window.location.href = 'http://localhost:8081/';
})
var customer = null;
var order = null;
checkCookie();
update_page();
function checkCookie() {
    let user = getCookie("user");
            let ord = getCookie("order")
            if (user != "") {
              customer = user
            } 
            if (ord != ""){
              order = ord
            }
          }
function update_shopping_list() {
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
                                <input type="number" id="qty_${dat[i].product_id}_${dat[i].order_id}" min="0" max="999" value="${dat[i].quantity}" />
                            </td>
                            <td>${dat[i].total}</td>
                        </tr>`;
                    
                }
        
                tableContent += `
                        </tbody>
                    </table>
                `;
        
                itemsList.innerHTML = tableContent;
        
                for (let i = 0; i < dat.length; ++i) {
                    const product_id = dat[i].product_id;
                    const order_id = dat[i].order_id;
                    const inputElement = document.getElementById(`qty_${product_id}_${order_id}`);
                    
                    inputElement.addEventListener("change", () => {
                        let q = inputElement.value;
                        updateCart(q, product_id);
                    });
                }
                document.getElementById("total_price").innerHTML = `<b><span>TOTAL</span> : ${total}`;
                if(curr_v.length == 0){
                    changeColor = 0;
                }
                if(changeColor != 0) document.getElementById("total_price").style.color = "green";
                else document.getElementById("total_price").style.color = "black";
            }
        }
        
        
async function getShoppingList(){
    const res = await fetch(`${url}getCart?customer_id=${customer}&order_id=${order}`,
        {
            method: 'GET',
            
            })
    const data = await res.json();
    dat = data.info;
    console.log(data);
    curr_v = data.Selected;
    total = data.total_price[0].total_price;
    update_shopping_list();
        }


async function getVouchers(){
    const res = await fetch(`${url}getVouchers?customer_id=${customer}&order_id=${order}`,
                {
                    method: 'GET',
                    
                    })
    const data = await res.json();
    vdat = data.info;
    console.log(data);
    update_voucher_list();
}

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
            if (ord != ""){
              order = ord
            }
          }

        



async function updateCart(qtt, id) {
        const res = await fetch(`${url}updateCart?customer_id=${customer}&order_id=${order}&product_id=${id}&quantity=${qtt}`, {
                method: 'GET'
        });
        if(qtt > 0) getShoppingList();
        else update_page();

        }

function update_voucher_list() {
            const vList = document.getElementById("vouchers_list");
            vList.innerHTML = "";  // Clear previous items
        
            if (vdat != null) {
                let listContent = `<ul class="voucher">`;
                let j = 0;
                for (let i = 0; i < vdat.length; ++i) {
                    let check = (vdat.length > 0 && j < curr_v.length && vdat[i].voucher_id == curr_v[i].voucher_id);
                    if(check) j++;
                    listContent += `
                        <li>
                        <input type="checkbox" id="voucher_${vdat[i].voucher_id}" value="${vdat[i].voucher_id}" ${check ? "checked = true" : ""}>
                        <label for="voucher_${vdat[i].voucher_id}">${vdat[i].name} : ${vdat[i].percent_off}% off ${vdat[i].product_name}</label>
                        </li>`;
                }
               
        
                listContent += `</ul>`;
                vList.innerHTML = listContent;
        
                for (let i = 0; i < vdat.length; ++i) {
                    const voucher_id = vdat[i].voucher_id;
                
                    const checkboxElement = document.getElementById(`voucher_${voucher_id}`);
                    
                    checkboxElement.addEventListener("change", () => {
                        let isChecked = checkboxElement.checked;
                        if(isChecked) changeColor ++;
                        else changeColor -- ;
                        handleVoucherSelection(isChecked, voucher_id);
                    });
                }
            }
        }
        
        async function handleVoucherSelection(isChecked, voucherId) {
            // Implement the logic to handle voucher selection here
            
            const res = await fetch(`${url}selectVouchers?customer_id=${customer}&order_id=${order}&voucher_id=${voucherId}&action=${isChecked? 1:0}`, {
                    method: 'GET'
            });
            getShoppingList();
            
            
        }
        
async function update_page(){
    const g1 = await getShoppingList();
    const g2 = await getVouchers();
}
 


function validateForm() {
    let isValid = true;
    let phone = document.getElementById("phone");
    let email = document.getElementById("email");
    let postalCode = document.getElementById("postal_code");

    const phoneRegex = /^[0-9]{10}$/;
    const postalCodeRegex = /^[A-Za-z0-9]{5,10}$/;

    if (!phoneRegex.test(phone.value)) {
        document.getElementById("phoneError").innerText = "Phone number must be 10 digits.";
        isValid = false;
    } else {
        document.getElementById("phoneError").innerText = "";
    }

    if (!postalCodeRegex.test(postalCode.value)) {
        document.getElementById("postalCodeError").innerText = "Postal code must be 5 to 10 alphanumeric characters.";
        isValid = false;
    } else {
        document.getElementById("postalCodeError").innerText = "";
    }

    return isValid;
}
        