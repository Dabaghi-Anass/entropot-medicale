import { useState } from 'react';
import { ChevronDown, ChevronUp, Building2 } from 'lucide-react';
import './resource-card.css';

export default function ResourcesAccordion({ resources }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className='resources-accordion quote-no-background '>
      <div className='accordion-container'>
        <button onClick={() => setIsOpen(!isOpen)} className='accordion-button'>
          <div className='accordion-header'>
            <Building2 className='accordion-icon' />
            <span className='accordion-title'>
              Resources ({resources.length})
            </span>
          </div>
          {isOpen ? (
            <ChevronUp className='accordion-chevron' />
          ) : (
            <ChevronDown className='accordion-chevron' />
          )}
        </button>

        {/* Content */}
        {isOpen && (
          <div className='accordion-content'>
            {resources.map((resource) => (
              <div key={resource.FacilityID} className='resource-item'>
                <div className='resource-name'>{resource.FacilityName}</div>
                <div className='resource-details'>
                  <div className='resource-detail'>
                    <span className='resource-label'>Location:</span>{' '}
                    {resource.City}, {resource.State} {resource.ZIPCode}
                  </div>
                  <div className='resource-detail'>
                    <span className='resource-label'>Address:</span>{' '}
                    {resource.Address}
                  </div>
                  <div className='resource-detail'>
                    <span className='resource-label'>Phone:</span>{' '}
                    {resource.Telephone}
                  </div>
                  <div className='resource-detail'>
                    <span className='resource-label'>Type:</span>{' '}
                    {resource.HospitalType}
                  </div>
                  <div className='resource-detail'>
                    <span className='resource-label'>Emergency Services:</span>{' '}
                    {resource.EmergencyServices}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
