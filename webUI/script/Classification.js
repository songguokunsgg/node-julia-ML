document.addEventListener('DOMContentLoaded', function () {
  document.getElementById('logistic').addEventListener('click', function () {
    showLogisticForm();
  });

  document.getElementById('naive-bayes').addEventListener('click', function () {
    showNaiveBayesForm();
  });

  document.getElementById('svm').addEventListener('click', function () {
    showSVMForm();
  });

  document.getElementById('kNN').addEventListener('click', function () {
    showKNNForm();
  });

  document.getElementById('decision-tree').addEventListener('click', function () {
    showDecisionTreeForm();
  });

  document.getElementById('random-forest').addEventListener('click', function () {
    showRandomForestForm();
  });

  document.getElementById('neural-network').addEventListener('click', function () {
    showNeuralNetworkForm();
  });
});

// 单独写一个函数处理数据的发送和回收
function FETCH(algoName, jsonData) {

  fetch("http://127.0.0.1:9999/" + algoName, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json'
    },
    body: jsonData
  })
    .then(response => response.json())
    .then(data => {
      console.log(data);
    })
    .catch(error => {
      console.error("Error:", error);
    });
}

async function showLogisticForm() {
  const mainContent = document.querySelector('.main-content');
  const response = await fetch('subHTML/logistic_form.html');
  const text = await response.text();
  mainContent.innerHTML = text;

  document.getElementById("submit-form").addEventListener("click", async function () {
    const fileInput = document.getElementById("data-file");
    const file = fileInput.files[0];
    if (file) {
      const text = await file.text();
      const learningRate = document.getElementById("learning-rate").value;
      const isFirstRowHeader = document.getElementById("first-row-is-header").checked;
      const jsonData = JSON.stringify({
        csvContent: text,
        learningRate: learningRate,
        method: "logistic",
        isFirstRowHeader: isFirstRowHeader
      });
      FETCH("logistic", jsonData);
    }
  });

}

async function showNaiveBayesForm() {
    const mainContent = document.querySelector('.main-content');
    const response = await fetch('subHTML/bayes.html');
    const text = await response.text();
    mainContent.innerHTML = text;
  
    document.getElementById("submit-form").addEventListener("click", async function () {
      const fileInput = document.getElementById("data-file");
      const file = fileInput.files[0];
      if (file) {
        const text = await file.text();
        const learningRate = document.getElementById("learning-rate").value;
        const isFirstRowHeader = document.getElementById("first-row-is-header").checked;
        const jsonData = JSON.stringify({
          csvContent: text,
          learningRate: learningRate,
          method: "bayes",
          isFirstRowHeader: isFirstRowHeader
        });
        FETCH("bayes", jsonData);;
      }
    });
  
  }

async function showSVMForm() {
  const mainContent = document.querySelector('.main-content');
  const response = await fetch('subHTML/svm.html');
  const text = await response.text();
  mainContent.innerHTML = text;

  document.getElementById("submit-form").addEventListener("click", async function () {
    const fileInput = document.getElementById("data-file");
    const file = fileInput.files[0];
    if (file) {
      const text = await file.text();
      const learningRate = document.getElementById("learning-rate").value;
      const isFirstRowHeader = document.getElementById("first-row-is-header").checked;
      const jsonData = JSON.stringify({
        csvContent: text,
        learningRate: learningRate,
        method: "svm",
        isFirstRowHeader: isFirstRowHeader
      });
      FETCH("svm", jsonData);
    }
  });
}

function showKNNForm() {
  const mainContent = document.querySelector('.main-content');
  mainContent.innerHTML = `
    <h2>k-近邻</h2>
    <form>
      <!-- 你的k-近邻特定字段在这里 -->
      
      <input type="submit" value="运行">
    </form>
  `;
}

function showDecisionTreeForm() {
  const mainContent = document.querySelector('.main-content');
  mainContent.innerHTML = `
    <h2>决策树</h2>
    <form>
      <!-- 你的决策树特定字段在这里 -->
      
      <input type="submit" value="运行">
    </form>
  `;
}

function showRandomForestForm() {
  const mainContent = document.querySelector('.main-content');
  mainContent.innerHTML = `
    <h2>随机森林</h2>
    <form>
      <!-- 你的随机森林特定字段在这里 -->
      
      <input type="submit" value="运行">
    </form>
  `;
}

function showNeuralNetworkForm() {
  const mainContent = document.querySelector('.main-content');
  mainContent.innerHTML = `
    <h2>神经网络</h2>
    <form>
      <!-- 你的神经网络特定字段在这里 -->
      
      <input type="submit" value="运行">
    </form>
  `;
}
