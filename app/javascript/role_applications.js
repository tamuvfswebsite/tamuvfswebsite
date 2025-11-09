// Role Applications - Dynamic Questions Display
function initializeRoleQuestions() {
  const roleSelect = document.getElementById('role_application_org_role_id');
  const questionsContainer = document.getElementById('application-questions');
  const rolesDataElement = document.getElementById('organizational-roles-data');
  
  if (!roleSelect || !questionsContainer || !rolesDataElement) {
    return;
  }
  
  let organizationalRoles;
  try {
    organizationalRoles = JSON.parse(rolesDataElement.textContent);
  } catch (e) {
    console.error('Failed to parse organizational roles data:', e);
    return;
  }
  
  function updateQuestions() {
    const selectedRoleId = parseInt(roleSelect.value);
    
    if (!selectedRoleId || isNaN(selectedRoleId)) {
      questionsContainer.innerHTML = '<p style="color: #666; font-style: italic;">Please select a role to see application questions.</p>';
      return;
    }
    
    const selectedRole = organizationalRoles.find(role => role.id === selectedRoleId);
    
    if (!selectedRole) {
      questionsContainer.innerHTML = '<p style="color: #666; font-style: italic;">Please select a role to see application questions.</p>';
      return;
    }
    
    let questionsHTML = '';
    
    if (selectedRole.question_1) {
      questionsHTML += `
        <div class="question-field" style="margin-bottom: 15px;">
          <label for="role_application_answer_1" style="display: block; font-weight: bold; margin-bottom: 5px;">
            ${escapeHtml(selectedRole.question_1)} (Minimum 50 characters)
          </label>
          <textarea name="role_application[answer_1]" id="role_application_answer_1" rows="10" 
                    placeholder="Your answer here..." 
                    style="width: 100%; padding: 8px; font-size: 14px; font-family: inherit;"></textarea>
        </div>
      `;
    }
    
    if (selectedRole.question_2) {
      questionsHTML += `
        <div class="question-field" style="margin-bottom: 15px;">
          <label for="role_application_answer_2" style="display: block; font-weight: bold; margin-bottom: 5px;">
            ${escapeHtml(selectedRole.question_2)} (Minimum 50 characters)
          </label>
          <textarea name="role_application[answer_2]" id="role_application_answer_2" rows="10" 
                    placeholder="Your answer here..." 
                    style="width: 100%; padding: 8px; font-size: 14px; font-family: inherit;"></textarea>
        </div>
      `;
    }
    
    if (selectedRole.question_3) {
      questionsHTML += `
        <div class="question-field" style="margin-bottom: 15px;">
          <label for="role_application_answer_3" style="display: block; font-weight: bold; margin-bottom: 5px;">
            ${escapeHtml(selectedRole.question_3)} (Minimum 50 characters)
          </label>
          <textarea name="role_application[answer_3]" id="role_application_answer_3" rows="10" 
                    placeholder="Your answer here..." 
                    style="width: 100%; padding: 8px; font-size: 14px; font-family: inherit;"></textarea>
        </div>
      `;
    }
    
    if (!questionsHTML) {
      questionsHTML = '<p style="color: #666; font-style: italic;">This role has no application questions. You may submit your application.</p>';
    }
    
    questionsContainer.innerHTML = questionsHTML;
  }
  
  // Helper function to escape HTML
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
  
  // Remove any existing listener to prevent duplicates
  const newSelect = roleSelect.cloneNode(true);
  roleSelect.parentNode.replaceChild(newSelect, roleSelect);
  
  // Add change event listener
  newSelect.addEventListener('change', updateQuestions);
  
  // Trigger immediately if a role is already selected
  if (newSelect.value) {
    setTimeout(updateQuestions, 0);
  }
}

// Initialize on page load and Turbo navigation
document.addEventListener('DOMContentLoaded', initializeRoleQuestions);
document.addEventListener('turbo:load', initializeRoleQuestions);
document.addEventListener('turbo:render', initializeRoleQuestions);
