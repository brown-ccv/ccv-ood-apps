/* 
 * Show only avail partitions with GPUs if GPU_PARTITIONS env var set
 * Show selected acct and partition even when advanced options not expanded
 * Show default models that will be available if advanced options not added
*/

document.addEventListener('DOMContentLoaded', function() {
  //Get the server data from the rails form view
  var selectedAcctPart = document.querySelector('[name="batch_connect_session_context[selected_account_partition]"]')
  var availModels = document.querySelector('[name="batch_connect_session_context[available_models]"]')
  var accountField = document.querySelector('[name="batch_connect_session_context[auto_accounts]"]');
  var partitionField = document.querySelector('[name="batch_connect_session_context[auto_queues]"]');
  var gpuPartitionsField = document.querySelector('[name="batch_connect_session_context[gpu_partitions]"]');
  var defaultPartitionField = document.querySelector('[name="batch_connect_session_context[default_partition]"]');
  
  //Create a div showing the selected acct and partition
  var selectedDiv = document.createElement('div');
  selectedDiv.id = "selected-acct-part";
  selectedDiv.style.margin = "0 0 1em 0";
  selectedAcctPart.parentNode.insertBefore(selectedDiv, selectedAcctPart);

  //Create a div showing the default models available
  var modelList = document.querySelector('[name="batch_connect_session_context[available_models]"]').value.split(",");
  var modelDiv = document.createElement('div');
  modelDiv.id = "avail-models";
  modelDiv.style.margin = "0 0 1em 0";
  availModels.parentNode.insertBefore(modelDiv, availModels);
  modelDiv.innerHTML =
    "<ul>" +
    modelList.map(m => "<li>" + m + "</li>").join("") +
    "</ul>" +
    "<em class='small'>NOTE: Expand the advanced options if you'd like to download a different model</em>";

  // Keep only GPU partitions in the Partition select and set default
  function filterPartitionsToGpu() {
    if (!partitionField || !gpuPartitionsField) return;

    var gpuValue = gpuPartitionsField.value || '';
    if (!gpuValue.trim()) return; // No GPU_PARTITIONS defined; show all partitions.

    var gpuList = gpuValue
      .split(',')
      .map(function(p) { return p.trim(); })
      .filter(function(p) { return p.length > 0; });

    if (!gpuList.length) return;

    // Remove non-GPU partitions from options
    Array.from(partitionField.options).forEach(function(opt) {
      if (!gpuList.includes(opt.value)) {
        opt.remove();
      }
    });

    // After removal, recompute available options
    var opts = Array.from(partitionField.options);
    if (!opts.length) return;

    var preferred = (defaultPartitionField && defaultPartitionField.value || '').trim();
    var newValue = null;

    if (opts.some(function(o) { return o.value === preferred; })) {
      newValue = preferred;
    } else {
      newValue = opts[0].value; // first available GPU partition
    }

    partitionField.value = newValue;
  }

  // Update the account and partition selections displayed if changed
  function updateSelectedDiv() {
    var acc = accountField.value;
    var part = partitionField.value;
    selectedDiv.innerHTML =
      "<ul style='margin-bottom:0;'><li>Account: " + acc +
      "</li><li>Partition: " + part + "</li></ul>";
  }

	// Partition change
  if (partitionField) {
    partitionField.addEventListener('change', updateSelectedDiv);
    
    // Initial setup
    filterPartitionsToGpu(); // Filter partitions to only GPU queues and set default
    updateSelectedDiv(); 
  }

  // Account change
  if (accountField){
    accountField.addEventListener('change', updateSelectedDiv);
  }

});
